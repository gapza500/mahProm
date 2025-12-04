import SwiftUI
import PetReadyShared

struct AdminSettingsScreen: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("⚙️ System Settings", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteRow(icon: "🎚️", title: "Feature toggles", subtitle: "Turn features on/off", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "🗺️", title: "Coverage areas", subtitle: "Manage service regions", showChevron: true)
                    }
                    cuteCard("👥 Team Management", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        cuteRow(icon: "👨‍💼", title: "Admin team", subtitle: "Manage administrators", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
                    }
                    Button(action: signOut) {
                        HStack {
                            Text("Sign Out")
                                .font(.body.weight(.semibold))
                            Image(systemName: "arrow.right.square.fill")
                        }
                        .foregroundStyle(.white)
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
                    VStack(spacing: 12) {
                        Text("🐾").font(.title)
                        Text("Made with love for pets").font(.caption).foregroundStyle(.secondary)
                        Text("🐶 🐱 🐰 🐹 🐦").font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("❤️ Settings")
        }
    }

    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
}
