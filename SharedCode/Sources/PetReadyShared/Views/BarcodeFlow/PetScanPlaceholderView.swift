import SwiftUI
#if canImport(AVFoundation) && canImport(UIKit)
import AVFoundation
import UIKit
#endif

public struct PetScanPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var claimViewModel: BarcodeClaimViewModel
    @State private var lastDetectedCode: String?
    @State private var isScannerPaused = false
    @State private var cameraMessage: String?
    private let onPetClaimed: ((Pet) -> Void)?

    public init(
        service: PetServiceProtocol? = nil,
        identityStore: OwnerIdentityStore = .shared,
        onPetClaimed: ((Pet) -> Void)? = nil
    ) {
        let resolvedService = service ?? PetService(repository: PetRepositoryFactory.makeRepository())
        self.onPetClaimed = onPetClaimed
        _claimViewModel = StateObject(
            wrappedValue: BarcodeClaimViewModel(
                service: resolvedService,
                identityStore: identityStore,
                onClaimed: onPetClaimed
            )
        )
    }

    public var body: some View {
        VStack(spacing: 24) {
            scannerSurface
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: Color.black.opacity(0.15), radius: 18, y: 10)

            VStack(spacing: 12) {
                if let code = lastDetectedCode {
                    Label("Latest code: \(code)", systemImage: "barcode")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Align your clinic barcode inside the frame. We'll auto-link your pet as soon as it's detected.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if claimViewModel.isSaving {
                    ProgressView("Linking pet…")
                        .padding(.top, 4)
                }

                if let message = claimViewModel.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let pet = claimViewModel.claimedPet {
                    scannerResultCard(for: pet)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Scan Barcode")
        .onChange(of: claimViewModel.isSaving) { saving in
            if !saving && claimViewModel.claimedPet == nil {
                isScannerPaused = false
            }
        }
        .onChange(of: claimViewModel.claimedPet) { pet in
            guard let pet else { return }
            isScannerPaused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onPetClaimed?(pet)
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var scannerSurface: some View {
#if canImport(AVFoundation) && canImport(UIKit)
        ZStack {
            if let cameraMessage = cameraMessage {
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.largeTitle)
                    Text(cameraMessage)
                        .multilineTextAlignment(.center)
                        .font(.callout)
                    Text("You can still register manually from the barcode form.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else {
                BarcodeCameraView(
                    isPaused: $isScannerPaused,
                    onCodeDetected: handleDetectedCode,
                    onError: { message in cameraMessage = message }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [12]))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .padding(24)
                )
                .overlay(alignment: .bottom) {
                    Text(isScannerPaused ? "Processing…" : "Hold steady…")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.bottom, 16)
                }
            }
        }
#else
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.largeTitle)
            Text("Barcode scanning requires an iOS device with camera access. Please use the manual entry form instead.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
#endif
    }

    private func scannerResultCard(for pet: Pet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Linked Pet")
                .font(.headline)
            Text(pet.name)
                .font(.title3.weight(.semibold))
            Text("Species: \(pet.species.rawValue.capitalized)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let barcode = pet.barcodeId {
                Text("Barcode: \(barcode)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, y: 6)
        )
    }

    private func handleDetectedCode(_ code: String) {
        guard !claimViewModel.isSaving else { return }
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        lastDetectedCode = normalized
        isScannerPaused = true
        claimViewModel.claimScannedCode(normalized)
#if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
    }
}

#if canImport(AVFoundation) && canImport(UIKit)
private struct BarcodeCameraView: UIViewControllerRepresentable {
    @Binding var isPaused: Bool
    let onCodeDetected: (String) -> Void
    let onError: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.onCodeDetected = { value in onCodeDetected(value) }
        controller.onPermissionIssue = { message in onError(message) }
        return controller
    }

    func updateUIViewController(_ controller: BarcodeScannerViewController, context: Context) {
        controller.isPaused = isPaused
        controller.onCodeDetected = { value in onCodeDetected(value) }
        controller.onPermissionIssue = { message in onError(message) }
    }
}

private final class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeDetected: ((String) -> Void)?
    var onPermissionIssue: ((String) -> Void)?
    var isPaused: Bool = false

    private let metadataQueue = DispatchQueue(label: "petready.barcode.metadata")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func configureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setUpCaptureSession() : self.onPermissionIssue?("Camera access denied. Enable it in Settings to scan barcodes.")
                }
            }
        default:
            onPermissionIssue?("Camera access denied. Enable it in Settings to scan barcodes.")
        }
    }

    private func setUpCaptureSession() {
        guard captureSession == nil else {
            captureSession?.startRunning()
            return
        }

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            onPermissionIssue?("Unable to access the camera on this device.")
            return
        }

        let session = AVCaptureSession()
        guard session.canAddInput(input) else {
            onPermissionIssue?("Cannot configure camera input for scanning.")
            return
        }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            onPermissionIssue?("Cannot process barcodes on this device.")
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: metadataQueue)
        output.metadataObjectTypes = [
            .qr,
            .code128,
            .code39,
            .code39Mod43,
            .code93,
            .ean13,
            .ean8,
            .pdf417,
            .aztec,
            .dataMatrix,
            .upce,
            .itf14,
            .interleaved2of5
        ]

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        self.previewLayer = previewLayer
        self.captureSession = session
        session.startRunning()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !isPaused,
              let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = metadata.stringValue else { return }

        isPaused = true
        DispatchQueue.main.async {
            self.onCodeDetected?(value)
        }
    }
}
#endif
