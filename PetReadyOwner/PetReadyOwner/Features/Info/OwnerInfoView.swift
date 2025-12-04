import SwiftUI
import PetReadyShared

struct OwnerInfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Government Alerts", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Alert Detail",
                                message: "Mock design for emergency broadcasts with deep links to push + realtime routes.",
                                icon: "📢",
                                highlights: ["Auto-broadcast to all role-specific apps"]
                            )
                            .navigationTitle("Heat Advisory")
                        } label: {
                            cuteInfoRow(icon: "📢", title: "Heat advisory for Bangkok", subtitle: "Broadcast to Owner + Vet apps", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }

                    cuteCard("Education", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Puppy Care Guide",
                                message: "Quick educational article layout sample with tags and share CTAs.",
                                icon: "📚",
                                highlights: ["Save for offline", "Share to chat threads"]
                            )
                            .navigationTitle("Puppy Care")
                        } label: {
                            cuteInfoRow(icon: "📚", title: "Puppy care basics", subtitle: "Tap to learn more", showChevron: true)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 50)
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Vaccination FAQ",
                                message: "FAQ layout referencing shared Firestore content collection.",
                                icon: "❓",
                                highlights: ["Search across answers", "Link to clinic booking"]
                            )
                            .navigationTitle("Vaccination FAQ")
                        } label: {
                            cuteInfoRow(icon: "❓", title: "Vaccination FAQ", subtitle: "Top questions answered", showChevron: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Information")
        }
    }
}
