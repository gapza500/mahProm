//
//  ContentView.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//

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
            List {
                Section("Your Pets") {
                    ForEach(0..<3, id: \.self) { index in
                        HStack {
                            Image(systemName: "pawprint.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text("Pet \(index + 1)")
                                    .font(.headline)
                                Text("Tap to view profile")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Next Actions") {
                    Label("Scan barcode to add pet", systemImage: "barcode.viewfinder")
                    Label("Issue digital health QR", systemImage: "qrcode")
                    Label("Create SOS request", systemImage: "exclamationmark.triangle.fill")
                }
            }
            .navigationTitle("Owner Home")
        }
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
