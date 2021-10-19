//
//  ConfSelectView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import SwiftUI

struct ClientSelectView: View {
    
    @StateObject var clientSelectVM = ClientSelectViewModel()
    
    var body: some View {
        VStack {
            if (clientSelectVM.availableClients.count < 1) {
                Text("noClients")
            } else {
                List(clientSelectVM.availableClients) { client in
                    Text("\(client.name)")
                }
            }
        }
        .navigationTitle("clientSelection")
        .onAppear() {
            clientSelectVM.getAvailableClients()
        }
    }
}

struct ClientSelectView_Previews: PreviewProvider {
static var previews: some View {
    NavigationView {
        ClientSelectView(clientSelectVM: ClientSelectViewModel(availableClients: Client.data))
            .previewDevice("iPad (9th generation)")
        }
        .navigationViewStyle(.stack)
        .previewDevice("iPad (9th generation)")
    }
}

