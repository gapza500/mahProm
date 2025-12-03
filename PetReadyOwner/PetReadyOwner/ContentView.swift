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
                .tabItem { Label("Home", systemImage: "house.fill") }
            OwnerPetsView()
                .tabItem { Label("Pets", systemImage: "pawprint.fill") }
            OwnerHealthView()
                .tabItem { Label("Health", systemImage: "cross.case.fill") }
            OwnerClinicsView()
                .tabItem { Label("Clinics", systemImage: "map.fill") }
            OwnerChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
            OwnerInfoView()
                .tabItem { Label("Info", systemImage: "info.circle.fill") }
            OwnerSettingsView()
                .tabItem { Label("Settings", systemImage: "heart.fill") }
        }
        .tint(Color(hex: "FF9ECD"))
        .environmentObject(authService)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService(apiClient: APIClient(baseURL: URL(string: "https://api.petready.app/v1")!)))
}
