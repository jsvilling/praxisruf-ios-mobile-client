//
//  HomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct HomeView: View {
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @StateObject private var homeVM = HomeViewModel()
    @ObservedObject var settings = Settings()
    
    var body: some View {
        TabView {
            IntercomView(configuration: $homeVM.configuration)
             .tabItem {
                 Image(systemName: "phone.fill")
                 Text("Home")
             }
            
            InboxView()
              .tabItem {
                  Image(systemName: "tray.and.arrow.down")
                  Text("Inbox")
               }
            SettingsView()
                .tabItem() {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .navigationTitle(settings.clientName)
        .onReceive(timer, perform: self.onInboxReminderTimerReceived)
        .onAppear(perform: self.onAppear)
    }
    
    func onInboxReminderTimerReceived(_ input: Any? = nil) {
        InboxReminderService.checkInbox()
    }
    
    func onAppear() {
        homeVM.loadConfiguration(clientId: settings.clientId)
        RegistrationService().register()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
