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
                    Toggle(isOn: !$settingsVM.isIncomingCallsDisabled) {
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

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
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
