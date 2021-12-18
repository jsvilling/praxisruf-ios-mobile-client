//
//  ConfSelectView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import SwiftUI

struct ClientSelectView: View {
    
    @StateObject var clientSelectVM = ClientSelectViewModel()
    @State var isEditMode: EditMode = .active
    
    var body: some View {
        VStack {
            if (clientSelectVM.availableClients.count < 1) {
                Text("noClients")
            } else {
                NavigationLink(destination: HomeView(clientName: clientSelectVM.selectedClient.name), isActive: $clientSelectVM.selectionConfirmed) {EmptyView()}.hidden()
                List(clientSelectVM.availableClients, selection: $clientSelectVM.selection) { client in
                    Text("\(client.name)")
                }
            }
        }
        .environment(\.editMode, $isEditMode)
        .navigationTitle("clientSelection")
        .navigationBarItems(trailing: Button("finish", action: {
            clientSelectVM.confirm()
            })
        )
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

