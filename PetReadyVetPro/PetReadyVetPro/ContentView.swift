import SwiftUI
import PetReadyShared

struct ContentView: View {
    var body: some View {
        RoleGateView(allowedRoles: [.vet, .clinic, .tester], loginView: { VetAuthView() }) {
            TabView {
                
                VetDashboardView()
                    .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2.fill") }
                
                
                PatientsView()
                    .tabItem { Label("Patients", systemImage: "stethoscope") }
                
                
                QueueMonitorView()
                    .tabItem { Label("Queue", systemImage: "clock.arrow.circlepath") }
                
                
                ContentHubView()
                    .tabItem { Label("Content", systemImage: "text.book.closed.fill") }
                
                
                VetSettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .tint(Color(hex: "FF9ECD"))
        }
    }
}
