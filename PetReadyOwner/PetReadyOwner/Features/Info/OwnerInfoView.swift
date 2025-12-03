import SwiftUI

struct OwnerInfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Government Alerts", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        cuteInfoRow(icon: "📢", title: "Heat advisory for Bangkok", subtitle: "Broadcast to Owner + Vet apps")
                    }

                    cuteCard("Education", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteInfoRow(icon: "📚", title: "Puppy care basics", subtitle: "Tap to learn more", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteInfoRow(icon: "❓", title: "Vaccination FAQ", subtitle: "Top questions answered", showChevron: true)
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Information")
        }
    }
}
