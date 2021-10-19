//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI

struct IntercomView: View {
    var body: some View {
        let clientName = UserDefaults.standard.string(forKey: "clientName") ?? "clientName"
        VStack {
            List {
                Section() {
                    Text("notifications")
                }
                Section {
                    Text("intercom")
                }
            }
        }
        .navigationTitle(clientName)
        .navigationBarBackButtonHidden(true)
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntercomView()
        }
        .navigationViewStyle(.stack)
    }
}
