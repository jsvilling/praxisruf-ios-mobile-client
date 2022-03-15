//
//  praxisruf_ios_mobile_clientApp.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 17.10.21.
//

import SwiftUI
import UIKit
import Firebase


/// Main class for the Praxisruf App.
/// On startup it registers the AppDelegate and shows the InitialView
@main
struct praxisruf_ios_mobile_clientApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                InitialView()
                    .environmentObject(AuthService())
                    .environmentObject(Settings())
            }
            .navigationViewStyle(.stack)
        }
    }
}
