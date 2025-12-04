import SwiftUI
import PetReadyShared

struct ContentView: View {
    var body: some View {
        RoleGateView(allowedRoles: [.admin, .tester], loginView: { AdminAuthView() }) {
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
}

#Preview {
    ContentView()
        .environmentObject(AuthService(previewRole: .admin))
}
