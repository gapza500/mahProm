import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RiderDashboardScreen()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            RiderJobsScreen()
                .tabItem { Label("Jobs", systemImage: "list.bullet.clipboard") }
            RiderWalletScreen()
                .tabItem { Label("Wallet", systemImage: "creditcard.fill") }
            RiderProfileScreen()
                .tabItem { Label("Profile", systemImage: "heart.fill") }
        }
        .tint(Color(hex: "A0D8F1"))
    }
}

#Preview {
    ContentView()
}
