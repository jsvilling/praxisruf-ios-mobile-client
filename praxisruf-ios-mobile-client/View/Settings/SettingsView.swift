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
                Section(header: Text("General")) {
                    HStack {
                        Text("Benutzer")
                        Spacer()
                        Text("Habenero")
                    }
                    HStack {
                        Text("Zimmer")
                        Spacer()
                        Text("Jalapeno")
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
        .onAppear(perform: settingsVM.load)
        .onDisappear(perform: settingsVM.save)
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
