//
//  WongiToolsApp.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 17/06/22.
//

import SwiftUI

@main
struct WongiToolsApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
