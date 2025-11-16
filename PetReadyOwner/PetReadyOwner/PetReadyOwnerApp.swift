//
//  PetReadyOwnerApp.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import PetReadyShared

@main
struct PetReadyOwnerApp: App {
    @StateObject private var authService: AuthService

    init() {
        AppBootstrap.configureFirebaseIfNeeded()
        let client = APIClient(baseURL: URL(string: "https://api.petready.app/v1")!)
        _authService = StateObject(wrappedValue: AuthService(apiClient: client))
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenContainer(appName: "PetReady Owner", accentColor: Color(red: 0.98, green: 0.48, blue: 0.63)) {
                ContentView()
                    .environmentObject(authService)
            }
        }
    }
}
