//
//  PetReadyCentralAdminApp.swift
//  PetReadyCentralAdmin
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import Combine
import Foundation
import PetReadyShared

@main
struct PetReadyCentralAdminApp: App {
    @StateObject private var appContext = CentralAdminContext()
    @StateObject private var authService = AuthService()

    init() {
        AppBootstrap.configureFirebaseIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenContainer(appName: "PetReady Admin", accentColor: Color(red: 0.18, green: 0.39, blue: 0.82)) {
                ContentView()
                    .environmentObject(appContext)
                    .environmentObject(authService)
            }
        }
    }
}

final class CentralAdminContext: ObservableObject {
    let cloudService: CloudSyncService?

    init() {
        #if canImport(CloudKit)
        if ProcessInfo.processInfo.environment["ENABLE_CLOUDKIT"] == "1" {
            cloudService = CloudSyncService(containerIdentifier: "iCloud.com.petready.shared")
        } else {
            cloudService = nil
        }
        #else
        cloudService = nil
        #endif
    }
}
