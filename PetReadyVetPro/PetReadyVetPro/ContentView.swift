import SwiftUI

struct ContentView: View {
    @State private var selectedRole: UserRole = .vet

    enum UserRole: String, CaseIterable, Identifiable {
        case vet = "Vet"
        case clinicAdmin = "Clinic Admin"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedRole == .vet {
                    VetDashboard()
                } else {
                    ClinicAdminDashboard()
                }
            }
            .navigationTitle("VetPro")
        }
    }
}

private struct VetDashboard: View {
    var body: some View {
        List {
            Section("Today’s Patients") {
                ForEach(0..<3, id: \.self) { idx in
                    NavigationLink("Patient #\(idx + 1)", destination: Text("Patient detail placeholder"))
                }
            }

            Section("Consultation Queue") {
                Label("5 waiting • Avg wait 4m", systemImage: "timer")
                Label("Next escalation in 10m", systemImage: "bolt.fill")
            }

            Section("Quick Actions") {
                Label("Open tele-chat room", systemImage: "message.fill")
                Label("Send prescription", systemImage: "pills.fill")
                Label("Start video handoff", systemImage: "video.fill")
            }
        }
    }
}

private struct ClinicAdminDashboard: View {
    var body: some View {
        List {
            Section("Clinic Overview") {
                Label("Operating hours set", systemImage: "clock")
                Label("4 vets on shift", systemImage: "person.3.fill")
            }

            Section("Campaigns") {
                NavigationLink("Wellness Week Promo", destination: Text("Campaign builder placeholder"))
                NavigationLink("Vaccination Drive", destination: Text("Campaign analytics placeholder"))
            }

            Section("Staff Management") {
                NavigationLink("Schedules", destination: Text("Schedule board"))
                NavigationLink("Permissions", destination: Text("Role management"))
            }
        }
    }
}

#Preview {
    ContentView()
}
