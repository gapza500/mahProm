import SwiftUI
import PetReadyShared

struct OwnerHealthView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Upcoming Vaccines", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            cuteInfoRow(icon: "💉", title: "Rabies Booster", subtitle: "Due in 7 days", badge: "Soon", badgeColor: Color(hex: "FFE5A0"))
                            if idx == 0 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }

                    cuteCard("Treatment Timeline", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<3, id: \.self) { idx in
                            cuteInfoRow(icon: "🩺", title: "Check-up visit", subtitle: "Feb \(15 + idx)", showChevron: true)
                            if idx < 2 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Health")
        }
    }
}
