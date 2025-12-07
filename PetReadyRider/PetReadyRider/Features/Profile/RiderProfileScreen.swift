import SwiftUI
import PetReadyShared

struct RiderProfileScreen: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Profile", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(hex: "FF9ECD"))
                                .frame(width: 70, height: 70)
                                .overlay(Text("🙂").font(.title))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authService.profile?.displayName ?? "PetReady Rider")
                                    .font(.title3.weight(.semibold))
                                Text(authService.profile?.email ?? "no-email@petready")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        Divider().padding(.vertical, 12)
                        riderCuteInfoRow(icon: "🆔", title: "Rider ID", subtitle: authService.profile?.id ?? "—")
                        riderCuteInfoRow(
                            icon: "📍",
                            title: "Status",
                            subtitle: authService.profile?.status.rawValue.capitalized ?? "Pending"
                        )
                    }

                    Button(action: signOut) {
                        HStack {
                            Text("Sign Out")
                                .font(.body.weight(.semibold))
                            Image(systemName: "arrow.right.square.fill")
                        }
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
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
                    Text("Made with 💖 for riders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
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
