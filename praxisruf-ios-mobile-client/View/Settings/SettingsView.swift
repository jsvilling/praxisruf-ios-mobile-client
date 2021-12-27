//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var settingsVM: Settings
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("General")) {
                    HStack {
                        Text("Benutzer")
                        Spacer()
                        Text(settingsVM.userName)
                    }
                    HStack {
                        Text("Zimmer")
                        Spacer()
                        Text(settingsVM.clientName)
                    }
                    Button(action: settingsVM.logout) {
                        Text("Abmelden")
                    }
                }
                Section(header: Text("Benachrichtigungen")) {
                    Toggle(isOn: $settingsVM.isSpeechSynthEnabled) {
                        Text("Benachrichtigungen vorlesen")
                    }
                }
                Section(header: Text("Gegensprechanalge")) {
                    Toggle(isOn: $settingsVM.isIncomingCallsEnabled) {
                        Text("Anrufe empfangen")
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
            SettingsView(settingsVM: Settings())
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
