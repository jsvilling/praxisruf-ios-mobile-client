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
    @Published var error: Error? = nil
    
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
                    DispatchQueue.main.async {
                        self.error = error
                    }
            }
        }
    }
    
    func confirm() {
        guard let clientId = selection else {
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.custom(errorMessage: "Selection incomplete")
            }
            return
        }
        
        guard let client = availableClients.first(where: { $0.id == clientId }) else {
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.custom(errorMessage: "Invalid data")
            }
            return
        }
    
        settings.clientId = clientId.uuidString
        settings.clientName = client.name
                
        DispatchQueue.main.async {
            self.selectionConfirmed  = true
        }
    }
}
