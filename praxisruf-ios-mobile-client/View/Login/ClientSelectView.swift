//
//  ConfSelectView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import SwiftUI

struct ClientSelectView: View {
    
    @StateObject var clientSelectVM = ClientSelectViewModel()
    @State private var selection: UUID?
    @State var isEditMode: EditMode = .active
    @State var isClientSelected = false
    
    var body: some View {
        VStack {
            if (clientSelectVM.availableClients.count < 1) {
                Text("noClients")
            } else {
                NavigationLink(destination: HomeView(), isActive: $isClientSelected) {EmptyView()}.hidden()
                List(clientSelectVM.availableClients, selection: $selection) { client in
                    Text("\(client.name)")
                }
            }
        }
        .environment(\.editMode, $isEditMode)
        .navigationTitle("clientSelection")
        .navigationBarItems(trailing: Button("finish", action: {
                guard let clientId = selection else {
                    return
                }
                
                guard let client = clientSelectVM.availableClients.first(where: { $0.id == clientId }) else {
                    return
                }
            
            UserDefaults.standard.setValue("\(clientId)", forKey: UserDefaultKeys.clientId)
            UserDefaults.standard.setValue(client.name, forKey: UserDefaultKeys.clientName)
                isClientSelected = true
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

