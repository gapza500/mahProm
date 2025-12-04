import SwiftUI
import PetReadyShared

struct OwnerSettingsView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Account", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        cuteInfoRow(icon: "👤", title: "Profile", subtitle: "Edit your info", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteInfoRow(icon: "🔔", title: "Notifications", subtitle: "Manage alerts", showChevron: true)
                    }

                    cuteCard("Preferences", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteInfoRow(icon: "🌐", title: "Language", subtitle: "TH / EN", showChevron: true)
                    }

                    Button {
                        do {
                            try authService.signOut()
                        } catch {
                            print("Failed to sign out: \(error.localizedDescription)")
                        }
                    } label: {
                        HStack {
                            Text("Logout")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        Text("Made with 💖 for pets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Settings")
        }
    }
}
