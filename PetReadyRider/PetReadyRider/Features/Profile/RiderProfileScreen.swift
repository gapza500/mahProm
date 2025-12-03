import SwiftUI

struct RiderProfileScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Identity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        riderCuteJobRow(icon: "📄", title: "Documents", subtitle: "Upload & verify", showChevron: true)
                        Divider().padding(.leading, 50)
                        riderCuteJobRow(icon: "🏍️", title: "Vehicle profile", subtitle: "Details & license", showChevron: true)
                    }
                    riderCuteCard("Service", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        riderCuteJobRow(icon: "🗺️", title: "Service areas", subtitle: "Coverage map", showChevron: true)
                        Divider().padding(.leading, 50)
                        riderCuteJobRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
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
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Profile")
        }
    }
}
