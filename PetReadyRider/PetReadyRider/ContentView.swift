import SwiftUI
import PetReadyShared

struct ContentView: View {
    var body: some View {
        RoleGateView(allowedRoles: [.rider, .tester], loginView: { RiderAuthView() }) {
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
}

#Preview {
    ContentView()
        .environmentObject(AuthService(previewRole: .rider))
}
