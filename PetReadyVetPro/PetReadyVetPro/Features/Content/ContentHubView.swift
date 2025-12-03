import SwiftUI

struct ContentHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    vetCuteCard("Campaigns", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        vetCuteActionRow(icon: "🎉", title: "Wellness Promo", subtitle: "Edit builder", showChevron: true)
                        Divider().padding(.leading, 50)
                        vetCuteActionRow(icon: "💉", title: "Vaccine Drive", subtitle: "View analytics", showChevron: true)
                    }
                    vetCuteCard("Content Library", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        vetCuteActionRow(icon: "📰", title: "Pet Flu Advisory", subtitle: "Draft ready", showChevron: true)
                        Divider().padding(.leading, 50)
                        vetCuteActionRow(icon: "📣", title: "Holiday Notice", subtitle: "Needs approval", badge: "New", badgeColor: Color(hex: "FF9ECD"), showChevron: true)
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Content Hub")
        }
    }
}
