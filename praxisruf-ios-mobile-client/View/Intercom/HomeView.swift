//
//  HomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import SwiftUI

struct HomeView: View {
    
    let clientName = UserDefaults.standard.string(forKey: "clientName") ?? "clientName"
    
    var body: some View {
        TabView {
           IntercomView()
             .tabItem {
                 Image(systemName: "phone.fill")
                 Text("Home")
             }
            
            InboxView(inboxItems: InboxItem.data)
              .tabItem {
                  Image(systemName: "tray.and.arrow.down")
                  Text("Inbox")
               }

        }
        .navigationTitle(clientName)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(.stack)
    }
}
