import SwiftUI
import PetReadyShared
#if canImport(UIKit)
import UIKit
#endif

struct HealthQRView: View {
    @StateObject private var viewModel: HealthQRViewModel

    init(pet: Pet? = nil) {
        _viewModel = StateObject(wrappedValue: HealthQRViewModel(initialPet: pet))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let pet = viewModel.pet {
                    VStack(spacing: 6) {
                        Text(pet.name)
                            .font(.title2.bold())
                        Text(pet.species.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)
                }

                if let image = viewModel.qrImage {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding()
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 12)
                } else {
                    ProgressView("Generating QR…").padding()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Contains")
                        .font(.headline)
                    ForEach(viewModel.summaryLines, id: \.self) { line in
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color(hex: "A0D8F1"))
                            Text(line)
                                .font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                )
            }
            .padding()
        }
        .background(DesignSystem.Colors.appBackground)
        .navigationTitle("Health QR")
        .task { await viewModel.load() }
    }
}

@MainActor
final class HealthQRViewModel: ObservableObject {
    @Published var pet: Pet?
    @Published var qrImage: UIImage?
    @Published var summaryLines: [String] = []

    private let petService: PetServiceProtocol
    private let healthService: HealthRecordServiceProtocol
    private let qrService = QRService()
    private let initialPet: Pet?

    init(
        initialPet: Pet?,
        petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository()),
        healthService: HealthRecordServiceProtocol = HealthRecordService.shared
    ) {
        self.initialPet = initialPet
        self.petService = petService
        self.healthService = healthService
    }

    func load() async {
        if let initialPet {
            pet = initialPet
        } else {
            if let first = try? await petService.loadPets().first {
                pet = first
            }
        }
        await generateQR()
    }

    private func generateQR() async {
        guard let pet else { return }
        let vaccines = await healthService.fetchVaccines(petId: pet.id)
        summaryLines = [
            "Species: \(pet.species.rawValue.capitalized)",
            "Latest vaccine: \(vaccines.first?.vaccineType ?? "N/A")",
            "Updated: \(Date().formatted(date: .abbreviated, time: .omitted))"
        ]
        let payload = [
            "petId": pet.id.uuidString,
            "name": pet.name,
            "species": pet.species.rawValue,
            "vaccines": vaccines.prefix(3).map { $0.vaccineType }
        ] as [String: Any]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: .sortedKeys),
           let string = String(data: data, encoding: .utf8),
           let image = try? qrService.generateImage(from: string) {
            qrImage = image
        }
    }
}
