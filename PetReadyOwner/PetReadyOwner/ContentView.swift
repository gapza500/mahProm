import SwiftUI
import PetReadyShared

struct ContentView: View {
    @State private var selectedTab: OwnerTab = .home

    var body: some View {
        RoleGateView(allowedRoles: [.owner, .tester], loginView: { OwnerAuthView() }) {
            TabView(selection: $selectedTab) {
                OwnerHomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(OwnerTab.home)
                OwnerPetsView()
                    .tabItem { Label("Pets", systemImage: "pawprint.fill") }
                    .tag(OwnerTab.pets)
                OwnerHealthView()
                    .tabItem { Label("Health", systemImage: "cross.case.fill") }
                    .tag(OwnerTab.health)
                OwnerChatView()
                    .tabItem { Label("Consult", systemImage: "stethoscope") }
                    .tag(OwnerTab.consult)
                OwnerMoreView()
                    .tabItem { Label("More", systemImage: "ellipsis.circle") }
                    .tag(OwnerTab.more)
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .tint(Color(hex: "FF9ECD"))
        }
    }
}

private enum OwnerTab: Hashable {
    case home, pets, health, consult, more
}

#Preview {
    ContentView()
        .environmentObject(AuthService(previewRole: .owner))
}
