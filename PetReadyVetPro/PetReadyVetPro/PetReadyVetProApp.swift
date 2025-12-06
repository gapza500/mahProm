//
//  PetReadyVetProApp.swift
//  PetReadyVetPro
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import Combine
import PetReadyShared

@main
struct PetReadyVetProApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) private var firebaseDelegate
    @StateObject private var appContext = VetProAppContext()
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            SplashScreenContainer(appName: "PetReady VetPro", accentColor: Color(red: 0.63, green: 0.45, blue: 0.90)) {
                ContentView()
                    .environmentObject(appContext)
                    .environmentObject(authService)
            }
        }
    }
}

final class VetProAppContext: ObservableObject {
    let chatService: ChatService

    init() {
        let url = URL(string: "wss://ws.petready.app")!
        let socket = SocketConnection(url: url)
        chatService = ChatService(socketConnection: socket)
    }
}
