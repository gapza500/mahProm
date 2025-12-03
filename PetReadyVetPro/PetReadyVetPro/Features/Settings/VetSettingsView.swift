import SwiftUI

struct VetSettingsView: View {
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
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Settings")
        }
    }
}
