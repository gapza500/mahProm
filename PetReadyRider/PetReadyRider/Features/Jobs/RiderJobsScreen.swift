import SwiftUI

struct RiderJobsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Available", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<5, id: \.self) { idx in
                            riderCuteJobRow(icon: "📦", title: "Job #\(idx + 300)", subtitle: "Standard delivery", showChevron: true)
                            if idx < 4 { Divider().padding(.leading, 50) }
                        }
                    }
                    riderCuteCard("Scheduled", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            riderCuteJobRow(
                                icon: "📅",
                                title: "Appointment \(idx + 1)",
                                subtitle: "Tomorrow 9:00",
                                badge: "Scheduled",
                                badgeColor: Color(hex: "FFE5A0")
                            )
                            if idx == 0 { Divider().padding(.leading, 50) }
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Jobs")
        }
    }
}
