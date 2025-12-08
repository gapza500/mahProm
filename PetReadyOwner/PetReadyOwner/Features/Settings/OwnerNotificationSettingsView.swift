import SwiftUI
import PetReadyShared

struct OwnerNotificationSettingsView: View {
    private let pushService: PushNotificationServiceProtocol
    @State private var permissionState: PushPermissionState
    @State private var isRequesting = false

    init(pushService: PushNotificationServiceProtocol = PushNotificationService()) {
        self.pushService = pushService
        _permissionState = State(initialValue: pushService.permissionState)
    }

    var body: some View {
        Form {
            Section(header: Text("Push permission")) {
                HStack {
                    Label(permissionDescription, systemImage: permissionIcon)
                        .foregroundStyle(permissionColor)
                    Spacer()
                }

                Button(action: requestPermission) {
                    if isRequesting {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Request permission")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isRequesting || permissionState == .granted)

                if permissionState == .denied {
                    Button("Open Settings", systemImage: "gear") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            Section(header: Text("Topics")) {
                Text("We will deliver care reminders and consultation updates to this device once permission is granted.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
    }

    private var permissionDescription: String {
        switch permissionState {
        case .notDetermined: return "Not determined"
        case .granted: return "Enabled"
        case .denied: return "Denied"
        }
    }

    private var permissionIcon: String {
        switch permissionState {
        case .notDetermined: return "questionmark.circle"
        case .granted: return "checkmark.circle"
        case .denied: return "xmark.octagon"
        }
    }

    private var permissionColor: Color {
        switch permissionState {
        case .notDetermined: return .orange
        case .granted: return .green
        case .denied: return .red
        }
    }

    private func requestPermission() {
        isRequesting = true
        Task { @MainActor in
            await pushService.requestPermission()
            permissionState = pushService.permissionState
            isRequesting = false
        }
    }
}

#Preview {
    NavigationStack {
        OwnerNotificationSettingsView()
    }
}
