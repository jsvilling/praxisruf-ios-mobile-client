//
//  ConfSelectView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import SwiftUI

struct ClientSelectView: View {
    
    @EnvironmentObject var auth: AuthService
    @StateObject var clientSelectVM = ClientSelectViewModel()
    @State var isEditMode: EditMode = .active
    
    var body: some View {
        VStack {
            if (clientSelectVM.availableClients.isEmpty) {
                Text("noClients")
            } else {
                NavigationLink(destination: HomeView().environmentObject(auth),
                               isActive: $clientSelectVM.selectionConfirmed) {EmptyView()}.hidden()
                List(clientSelectVM.availableClients, selection: $clientSelectVM.selection) { client in
                    Text("\(client.name)")
                }
            }
        }
        .environment(\.editMode, $isEditMode)
        .navigationTitle("clientSelection")
        .navigationBarItems(trailing: Button("finish", action: clientSelectVM.confirm))
        .onAppear(perform: clientSelectVM.getAvailableClients)
        .onError(clientSelectVM.error, retryHandler: {})
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

