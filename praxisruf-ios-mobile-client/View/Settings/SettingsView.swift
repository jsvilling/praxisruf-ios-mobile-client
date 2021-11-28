//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Benachrichtigungen")) {
                Text("Mute Text To Speech")
            }
            Section(header: Text("Gegensprechanalge")) {
                Text("Do not disturb")
            }
            Section(header: Text("Client")) {
                Text("Benutzer")
                Text("Angemeldet bleiben")
                Button(action: logout) {
                    Text("Abmelden")
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    func logout() {
        print("logout")
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
