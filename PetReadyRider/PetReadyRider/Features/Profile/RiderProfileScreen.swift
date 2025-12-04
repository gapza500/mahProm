import SwiftUI
import PetReadyShared

struct RiderProfileScreen: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Identity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Rider Documents",
                                message: "Placeholder for ID/passport upload bound to Firestore profile docs.",
                                icon: "🪪",
                                highlights: ["KYC checklist", "Status per document"]
                            )
                            .navigationTitle("Documents")
                        } label: {
                            riderCuteJobRow(icon: "📄", title: "Documents", subtitle: "Upload & verify", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Vehicle Details",
                                message: "Garage for license plate, insurance and inspection photos.",
                                icon: "🏍️",
                                highlights: ["Multiple vehicle slots", "Reminder for renewals"]
                            )
                            .navigationTitle("Vehicle Profile")
                        } label: {
                            riderCuteJobRow(icon: "🏍️", title: "Vehicle profile", subtitle: "Details & license", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    riderCuteCard("Service", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Service Areas",
                                message: "Map-driven settings to limit dispatch radius.",
                                icon: "🗺️",
                                highlights: ["Uses shared GPS stub", "Area opt-in/out"]
                            )
                            .navigationTitle("Service Areas")
                        } label: {
                            riderCuteJobRow(icon: "🗺️", title: "Service areas", subtitle: "Coverage map", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Alert Preferences",
                                message: "Pick which push/realtime topics the rider wants.",
                                icon: "🔔",
                                highlights: ["Quiet hours", "Job type subscriptions"]
                            )
                            .navigationTitle("Notifications")
                        } label: {
                            riderCuteJobRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }

                    riderCuteCard("Foundation", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        NavigationLink {
                            InfrastructurePreviewView()
                        } label: {
                            riderCuteJobRow(icon: "🛰️", title: "Base infrastructure", subtitle: "GPS • realtime • push", showChevron: true)
                        }
                        .buttonStyle(.plain)
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
