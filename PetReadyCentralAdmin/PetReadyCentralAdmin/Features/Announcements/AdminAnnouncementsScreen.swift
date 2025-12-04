import SwiftUI
import PetReadyShared

struct AdminAnnouncementsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("🔴 Active Alerts", gradient: [Color(hex: "FFE5E5"), Color(hex: "FFF0F0")]) {
                        cuteRow(
                            icon: "☀️",
                            title: "Heat warning: Bangkok",
                            subtitle: "Sent to all pet parents & vets",
                            badge: "Live",
                            badgeColor: Color(hex: "FF9ECD"),
                            showChevron: true
                        )
                    }
                    cuteCard("📝 Draft Messages", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        cuteRow(
                            icon: "🤧",
                            title: "Pet flu advisory",
                            subtitle: "Scheduled for tomorrow 9 AM",
                            badge: "Tomorrow",
                            badgeColor: Color(hex: "FFE5A0"),
                            showChevron: true
                        )
                        Divider().padding(.leading, 50)
                        cuteRow(
                            icon: "🎉",
                            title: "Holiday closure notice",
                            subtitle: "Waiting for final approval",
                            showChevron: true
                        )
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("🔔 Alerts")
        }
    }
}
