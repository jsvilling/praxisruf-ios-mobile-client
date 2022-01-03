//
//  ConfSelectView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import SwiftUI

struct ClientSelectView: View {
    
    @EnvironmentObject var auth: AuthService
    @StateObject var clientsService = ClientsService()
    @State var isEditMode: EditMode = .active
    @State var selection: UUID?
    @State var selectionComplete = false
    
    var body: some View {
        VStack {
            if (clientsService.availableClients.isEmpty) {
                Text("noClients")
            } else {
                NavigationLink(destination: HomeView().environmentObject(auth),
                               isActive: $selectionComplete) {EmptyView()}.hidden()
                List(clientsService.availableClients, selection: $selection) { client in
                    Text("\(client.name)")
                }
            }
        }
        .environment(\.editMode, $isEditMode)
        .navigationTitle("clientSelection")
        .navigationBarItems(trailing: Button("finish", action: confirm))
        .onAppear(perform: clientsService.getAvailableClients)
        .onError(clientsService.error, retryHandler: {})
    }
    
    private func confirm() {
        clientsService.confirm(selection: selection)
        selectionComplete = clientsService.error == nil
    }
}

struct ClientSelectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientSelectView(clientsService: ClientsService(availableClients: Client.data))
                .previewDevice("iPad (9th generation)")
            }
            .navigationViewStyle(.stack)
            .previewDevice("iPad (9th generation)")
    }
}

