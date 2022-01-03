//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var settings: Settings
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("General")) {
                    HStack {
                        Text("Benutzer")
                        Spacer()
                        Text(settings.userName)
                    }
                    HStack {
                        Text("Zimmer")
                        Spacer()
                        Text(settings.clientName)
                    }
                    Button(action: auth.logout) {
                        Text("Abmelden")
                    }
                }
                Section(header: Text("Benachrichtigungen")) {
                    Toggle(isOn: $settings.isSpeechSynthEnabled) {
                        Text("Benachrichtigungen vorlesen")
                    }
                }
                Section(header: Text("Gegensprechanalge")) {
                    Toggle(isOn: !$settings.isIncomingCallsDisabled) {
                        Text("Anrufe empfangen")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(settings: Settings.standard)
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
