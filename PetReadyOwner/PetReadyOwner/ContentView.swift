//
//  ContentView.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//
//kim are here
import SwiftUI
import PetReadyShared

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView {
            OwnerHomeView()
                .tabItem { 
                    Label("Home", systemImage: "house.fill")
                }

            OwnerPetsView()
                .tabItem { 
                    Label("Pets", systemImage: "pawprint.fill")
                }

            OwnerHealthView()
                .tabItem { 
                    Label("Health", systemImage: "cross.case.fill")
                }

            OwnerClinicsView()
                .tabItem { 
                    Label("Clinics", systemImage: "map.fill")
                }

            OwnerChatView()
                .tabItem { 
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }

            OwnerInfoView()
                .tabItem { 
                    Label("Info", systemImage: "info.circle.fill")
                }

            OwnerSettingsView()
                .tabItem { 
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

private struct OwnerHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    homeHeroCard
                    statusGrid
                    quickHubCard
                    infoStack(title: "Upcoming Care", rows: ["Rabies booster • 7 days", "General check-up • Mar 24"])
                    infoStack(title: "Emergency Toolkit", rows: ["SOS profile up to date", "Nearest trusted clinic: PetWell Siam"])
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Owner Home")
        }
    }

    private var homeHeroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Fluffy & Basil are protected today.")
                .font(.title3.bold())
            HStack {
                Label("2 vaccines soon", systemImage: "syringe.fill")
                    .foregroundStyle(.pink)
                Spacer()
                Button("Care plan") {}
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statusTile(icon: "pawprint.fill", title: "Pets", subtitle: "3 active", color: .pink)
            statusTile(icon: "timer", title: "Chat wait", subtitle: "<5 min", color: .orange)
            statusTile(icon: "cross.case.fill", title: "Vaccines", subtitle: "2 due soon", color: .blue)
            statusTile(icon: "location.circle.fill", title: "Nearby vet", subtitle: "1.2 km", color: .green)
        }
    }

    private func statusTile(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .padding(10)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(subtitle)
                .font(.headline)
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var quickHubCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Hub")
                .font(.headline)
            ForEach([
                ("barcode.viewfinder", "Register via Barcode", "Scan physical tag"),
                ("qrcode", "Issue Health QR", "Share vaccine proof"),
                ("exclamationmark.triangle.fill", "Start SOS", "Dispatch rider + clinic")
            ], id: \.0) { item in
                HStack {
                    Image(systemName: item.0)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    VStack(alignment: .leading) {
                        Text(item.1).bold()
                        Text(item.2)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }.padding(.vertical, 6)
            }
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    private func infoStack(title: String, rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ForEach(rows, id: \.self) { row in
                HStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.25))
                        .frame(width: 10, height: 10)
                    Text(row).font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct OwnerPetsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<5, id: \.self) { index in
                    NavigationLink("Fluffy \(index + 1)", destination: Text("Pet detail placeholder"))
                }
            }
            .navigationTitle("Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {}
                }
            }
        }
    }
}

private struct OwnerHealthView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Upcoming Vaccines") {
                    ForEach(0..<2, id: \.self) { _ in
                        VStack(alignment: .leading) {
                            Text("Rabies Booster")
                                .font(.headline)
                            Text("Due in 7 days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Treatment Timeline") {
                    ForEach(0..<3, id: \.self) { _ in
                        Text("Visit summary placeholder")
                    }
                }
            }
            .navigationTitle("Health")
        }
    }
}

private struct OwnerClinicsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<4, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Vet Clinic \(index + 1)")
                            .font(.headline)
                        Text("Tap to view map, promotions, booking")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Clinics")
        }
    }
}

private struct OwnerChatView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Waiting Queue") {
                    Label("Dr. Siri — ETA 5 min", systemImage: "timer")
                }
                Section("Conversations") {
                    ForEach(0..<2, id: \.self) { _ in
                        NavigationLink("Vet chat placeholder", destination: Text("Chat room"))
                    }
                }
            }
            .navigationTitle("Chat")
        }
    }
}

private struct OwnerInfoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Government Alerts") {
                    Label("Heat advisory for Bangkok", systemImage: "megaphone.fill")
                }
                Section("Education") {
                    Label("Puppy care basics", systemImage: "book.fill")
                    Label("Vaccination FAQ", systemImage: "questionmark.circle")
                }
            }
            .navigationTitle("Information")
        }
    }
}

private struct OwnerSettingsView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Profile", destination: Text("Profile screen placeholder"))
                NavigationLink("Notifications", destination: Text("Notification controls"))
                NavigationLink("Language", destination: Text("TH / EN picker"))
                Button("Logout") {
                    authService.logout()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService(apiClient: APIClient(baseURL: URL(string: "https://api.petready.app/v1")!)))
}
