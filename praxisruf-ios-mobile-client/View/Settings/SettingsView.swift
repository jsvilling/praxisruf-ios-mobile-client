//
//  SettingsView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settings: Settings
    
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
                    Button(action: settings.logout) {
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
            NavigationLink(destination: LoginView(), isActive: $settings.isLoggedOut) {EmptyView()}.hidden()
        }
        .navigationBarBackButtonHidden(true)
    }
}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
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
