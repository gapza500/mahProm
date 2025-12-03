import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AdminDashboardScreen()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            AdminApprovalsScreen()
                .tabItem { Label("Approvals", systemImage: "checkmark.circle.fill") }
            AdminAnnouncementsScreen()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
            AdminAnalyticsScreen()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
            AdminSettingsScreen()
                .tabItem { Label("Settings", systemImage: "heart.fill") }
        }
        .tint(Color(hex: "FF9ECD"))
    }
}

#Preview {
    ContentView()
}
