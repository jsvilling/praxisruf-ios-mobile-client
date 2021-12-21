//
//  HomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var homeVM = HomeViewModel()
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let clientName: String
    
    init (clientName: String?) {
        self.clientName = clientName ?? UserDefaults.standard.string(forKey: "clientName") ?? "UNKNOWN"
    }
    
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
        .navigationTitle(clientName)
        .onReceive(timer) { input in
            InboxReminderService.checkInbox()
        }
        .onAppear() {
            homeVM.loadConfiguration()
            RegistrationService().register()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(clientName: "ClientName")
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
