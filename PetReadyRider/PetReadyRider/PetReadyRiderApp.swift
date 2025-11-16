//
//  PetReadyRiderApp.swift
//  PetReadyRider
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import Combine
import PetReadyShared

@main
struct PetReadyRiderApp: App {
    @StateObject private var appContext = RiderAppContext()

    init() {
        AppBootstrap.configureFirebaseIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenContainer(appName: "PetReady Rider", accentColor: Color(red: 0.21, green: 0.73, blue: 0.73)) {
                ContentView()
                    .environmentObject(appContext)
            }
        }
    }
}

final class RiderAppContext: ObservableObject {
    let sosService = SOSService()
    let mapsService = MapsService()
}
