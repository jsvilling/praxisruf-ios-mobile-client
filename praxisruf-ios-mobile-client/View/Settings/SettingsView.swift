//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("settings.generel")) {
                    HStack {
                        Text("settings.user")
                        Spacer()
                        Text(auth.userName)
                    }
                    HStack {
                        Text("settings.clientName")
                        Spacer()
                        Text(settings.clientName)
                    }
                    Button(action: auth.logout) {
                        Text("logout")
                    }
                }
                Section(header: Text("notifications")) {
                    Toggle(isOn: $settings.isSpeechSynthEnabled) {
                        Text("settings.speechSynthEnabled")
                    }
                }
                Section(header: Text("intercom")) {
                    Toggle(isOn: !$settings.isIncomingCallsDisabled) {
                        Text("settings.incommingCallsEnabled")
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
            SettingsView()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
