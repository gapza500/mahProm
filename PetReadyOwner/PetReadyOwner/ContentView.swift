//
//  ContentView.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import PetReadyShared

struct ContentView: View {
    var body: some View {
        RoleGateView(allowedRoles: [.owner, .tester], loginView: { OwnerAuthView() }) {
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
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .tint(Color(hex: "FF9ECD"))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService(previewRole: .owner))
}
