//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var settingsVM: SettingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
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
                    Button(action: settingsVM.logout) {
                        Text("Abmelden")
                    }

                }
            }
            .listStyle(InsetGroupedListStyle())
            NavigationLink(destination: LoginView(), isActive: $settingsVM.isLoggedOut) {EmptyView()}.hidden()
        }
        .navigationBarBackButtonHidden(true)
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
