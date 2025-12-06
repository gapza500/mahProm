//
//  PetReadyVetProApp.swift
//  PetReadyVetPro
//
//  Created by - Jhongi on 16/11/2568 BE.
//
import SwiftUI
import PetReadyShared

@main
struct PetReadyVetProApp: App {
    @StateObject private var authService: AuthService

    init() {
        AppBootstrap.configureFirebaseIfNeeded()
        _authService = StateObject(wrappedValue: AuthService())
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenContainer(appName: "PetReady Vet", accentColor: .green) {
                // เรียกใช้ ContentView ที่อยู่ในอีกไฟล์นึง
                ContentView()
                    .environmentObject(authService)
            }
        }
    }
}
