//
//  ConfSelectViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class ClientSelectViewModel: ObservableObject {
    
    @Published var availableClients: [Client]
    @Published var selectionConfirmed: Bool
    var selectedClient: Client
    var selection: UUID?
    
    init(availableClients: [Client] = []) {
        self.availableClients = availableClients
        self.selectionConfirmed = false
        self.selection = nil
        self.selectedClient = Client(id: UUID(), name: "")
    }
    
    func getAvailableClients() {
        PraxisrufApi().getAvailableClients() { result in
            switch result {
                case .success(let clients):
                    DispatchQueue.main.async {
                        self.availableClients = clients
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func confirm() {
        guard let clientId = selection else {
            return
        }
        
        guard let client = availableClients.first(where: { $0.id == clientId }) else {
            return
        }
    
        UserDefaults.standard.setValue("\(clientId)", forKey: UserDefaultKeys.clientId)
        UserDefaults.standard.setValue(client.name, forKey: UserDefaultKeys.clientName)
        self.selectedClient = client
        self.selectionConfirmed  = true
    }
}
