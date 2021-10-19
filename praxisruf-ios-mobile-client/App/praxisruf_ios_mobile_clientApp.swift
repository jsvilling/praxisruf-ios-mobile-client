//
//  praxisruf_ios_mobile_clientApp.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 17.10.21.
//

import SwiftUI

@main
struct praxisruf_ios_mobile_clientApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
            }
            .navigationViewStyle(.stack)
        }
    }
}
