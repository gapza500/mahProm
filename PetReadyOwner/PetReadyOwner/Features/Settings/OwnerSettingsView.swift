import SwiftUI
import PetReadyShared

struct OwnerSettingsView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Account", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Profile Editor",
                                message: "Preview of the form we'll wire up to Firestore profiles.",
                                icon: "👤",
                                highlights: ["Display name & contact", "Toggle between pets"]
                            )
                            .navigationTitle("Profile")
                        } label: {
                            cuteInfoRow(icon: "👤", title: "Profile", subtitle: "Edit your info", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Notifications",
                                message: "Control push + realtime topics per owner.",
                                icon: "🔔",
                                highlights: ["SOS escalation topic", "Clinic booking reminders"]
                            )
                            .navigationTitle("Notifications")
                        } label: {
                            cuteInfoRow(icon: "🔔", title: "Notifications", subtitle: "Manage alerts", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }

                    cuteCard("Preferences", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Language + Theme",
                                message: "Toggle between Thai / English and dark mode roadmap.",
                                icon: "🌐",
                                highlights: ["Persisted via AppStorage"]
                            )
                            .navigationTitle("Preferences")
                        } label: {
                            cuteInfoRow(icon: "🌐", title: "Language", subtitle: "TH / EN", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }

                    cuteCard("Foundation", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        NavigationLink {
                            InfrastructurePreviewView()
                        } label: {
                            cuteInfoRow(icon: "🛠️", title: "Base infrastructure", subtitle: "GPS • realtime • push", showChevron: true)
                        }
                        .buttonStyle(.plain)
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
                                .foregroundStyle(DesignSystem.Colors.onAccentText)
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundStyle(DesignSystem.Colors.onAccentText)
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
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Settings")
        }
    }
}
