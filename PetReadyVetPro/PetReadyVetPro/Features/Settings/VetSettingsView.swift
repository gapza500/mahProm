import SwiftUI
import PetReadyShared

struct VetSettingsView: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    vetCuteCard("Doctor Profile", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        vetCuteInfoRow(icon: "👩‍⚕️", title: "Dr. Siri", subtitle: "Edit details", showChevron: true)
                    }
                    vetCuteCard("Practice", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        vetCuteActionRow(icon: "📅", title: "Availability", subtitle: "Manage schedule", showChevron: true)
                        Divider().padding(.leading, 50)
                        vetCuteActionRow(icon: "🏷️", title: "Pricing", subtitle: "Consultation fees", showChevron: true)
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
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Settings")
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
