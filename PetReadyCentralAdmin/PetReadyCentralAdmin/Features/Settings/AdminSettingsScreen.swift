import SwiftUI
import PetReadyShared

struct AdminSettingsScreen: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("⚙️ System Settings", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Feature Toggles",
                                message: "Control center for enabling role-based modules per region.",
                                icon: "🎚️",
                                highlights: ["Gradual rollout", "Audit logging"]
                            )
                            .navigationTitle("Feature Toggles")
                        } label: {
                            cuteRow(icon: "🎚️", title: "Feature toggles", subtitle: "Turn features on/off", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Coverage Areas",
                                message: "Admin mapping surface to expand serviceable areas.",
                                icon: "🗺️",
                                highlights: ["Syncs with GPS filters", "Exports to Rider app"]
                            )
                            .navigationTitle("Coverage Areas")
                        } label: {
                            cuteRow(icon: "🗺️", title: "Coverage areas", subtitle: "Manage service regions", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    cuteCard("👥 Team Management", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Admin Team",
                                message: "Assign roles + scopes for central operators.",
                                icon: "👨‍💼",
                                highlights: ["Per-module permissions", "Invite links"]
                            )
                            .navigationTitle("Admin Team")
                        } label: {
                            cuteRow(icon: "👨‍💼", title: "Admin team", subtitle: "Manage administrators", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Admin Alerts",
                                message: "Pick which push topics each admin receives.",
                                icon: "🔔",
                                highlights: ["Escalation tiers", "SMS failover"]
                            )
                            .navigationTitle("Notifications")
                        } label: {
                            cuteRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    cuteCard("Foundation", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        NavigationLink {
                            InfrastructurePreviewView()
                        } label: {
                            cuteRow(icon: "🛰️", title: "Base infrastructure", subtitle: "GPS • realtime • push", showChevron: true)
                        }
                        .buttonStyle(.plain)
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
            .background(DesignSystem.Colors.appBackground)
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
