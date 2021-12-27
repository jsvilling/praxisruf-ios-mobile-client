//
//  ConfSelectViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation
import SwiftUI

class ClientSelectViewModel: ObservableObject {
    
    @Published var availableClients: [Client]
    @Published var selectionConfirmed: Bool
    @Published var selection: UUID?
    
    @ObservedObject var settings: Settings = Settings()
    
    init(availableClients: [Client] = []) {
        self.availableClients = availableClients
        self.selectionConfirmed = false
        self.selection = nil
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
    
        settings.clientId = clientId.uuidString
        settings.clientName = client.name
        
        UserDefaults.standard.setValue(client.name, forKey: UserDefaultKeys.clientName)
        
        DispatchQueue.main.async {
            self.selectionConfirmed  = true
        }
    }
}
