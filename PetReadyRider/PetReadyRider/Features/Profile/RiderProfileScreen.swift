import SwiftUI
import PetReadyShared

struct RiderProfileScreen: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Identity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        riderCuteJobRow(icon: "📄", title: "Documents", subtitle: "Upload & verify", showChevron: true)
                        Divider().padding(.leading, 50)
                        riderCuteJobRow(icon: "🏍️", title: "Vehicle profile", subtitle: "Details & license", showChevron: true)
                    }
                    riderCuteCard("Service", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        riderCuteJobRow(icon: "🗺️", title: "Service areas", subtitle: "Coverage map", showChevron: true)
                        Divider().padding(.leading, 50)
                        riderCuteJobRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
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
                                colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .shadow(color: Color(hex: "A0D8F1").opacity(0.3), radius: 12, y: 6)
                    }
                    VStack(spacing: 12) {
                        Text("Made with 💖 for riders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Profile")
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
