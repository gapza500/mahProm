import SwiftUI
import PetReadyShared

struct VetSettingsView: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    vetCuteCard("Doctor Profile", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Doctor Profile",
                                message: "Form layout for vet credentials, clinics, and messaging preferences.",
                                icon: "👩‍⚕️",
                                highlights: ["License uploads", "Availability toggle"]
                            )
                            .navigationTitle("Doctor Profile")
                        } label: {
                            vetCuteInfoRow(icon: "👩‍⚕️", title: "Dr. Siri", subtitle: "Edit details", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                    vetCuteCard("Practice", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Clinic Availability",
                                message: "Scheduler referencing the shared realtime queue service.",
                                icon: "📅",
                                highlights: ["Block leave days", "Sync to owner booking"]
                            )
                            .navigationTitle("Availability")
                        } label: {
                            vetCuteActionRow(icon: "📅", title: "Availability", subtitle: "Manage schedule", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Pricing",
                                message: "Tiered price list tied to clinics and service codes.",
                                icon: "🏷️",
                                highlights: ["Per-role visibility", "Seasonal promos"]
                            )
                            .navigationTitle("Pricing")
                        } label: {
                            vetCuteActionRow(icon: "🏷️", title: "Pricing", subtitle: "Consultation fees", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }

                    vetCuteCard("Foundation", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        NavigationLink {
                            InfrastructurePreviewView()
                        } label: {
                            vetCuteActionRow(icon: "🛰️", title: "Base infrastructure", subtitle: "GPS • realtime • push", showChevron: true)
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
            .background(DesignSystem.Colors.appBackground)
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
