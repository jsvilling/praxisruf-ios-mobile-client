//
//  HomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct HomeView: View {
    
    let inboxReminderTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()     // Every 60s
    let tokenRefreshTimer = Timer.publish(every: 43200, on: .main, in: .common).autoconnect()   // Every 12h
    
    @StateObject private var homeVM = HomeViewModel()
    @StateObject var settings = Settings.standard
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        ZStack {
            NavigationLink(destination: LoginView(), isActive: !$auth.isAuthenticated) {EmptyView()}.hidden()
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
                SettingsView(settings: settings)
                    .environmentObject(auth)
                    .tabItem() {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                
            }
        }
        .navigationTitle(settings.clientName)
        .onReceive(inboxReminderTimer, perform: self.onInboxReminderTimerReceived)
        .onAppear(perform: self.onAppear)
        .onError(auth.error)
        .onError(homeVM.error)
    }
    
    func onInboxReminderTimerReceived(_ input: Any? = nil) {
        InboxReminderService.checkInbox()
    }
    
    func onTokenRefreshTimer(_ input: Any? = nil) {
        auth.refresh()
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
