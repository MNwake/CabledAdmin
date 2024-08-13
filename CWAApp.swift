//
//  CWAApp.swift
//  CWA
//
//  Created by Theo Koester on 3/19/24.
//

import SwiftUI
import Firebase


@main
struct TheCWA_adminApp: App {
    @Environment(\.scenePhase) var scenePhase
    let websocketHandler = WebSocketHandler.shared

    init() {
        let websocketURL = URL(string: WEBSOCKET_URL)!
        websocketHandler.connect(to: websocketURL)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { newScenePhase in
                    switch newScenePhase {
                    case .active:
                        // App has become active
                        print("App is active")
                        websocketHandler.connect(to: URL(string: WEBSOCKET_URL)!)
                    case .background:
                        // App has moved to the background
                        print("App is in background")
                        websocketHandler.disconnect()
                    case .inactive:
                        // App is inactive
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}
