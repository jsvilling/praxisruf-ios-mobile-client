//
//  ConfSelectViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation
import SwiftUI

/// A Client in praxisruf is the representation of a single device in the configuration api of praxisruf.
/// This service enables selecting and loading client information from the configuration api of the cloudservice.
/// It published properties to display a list of availableClients as well as errors related to loading said clients.
/// It also provides methods to load and select available Clients.
class ClientsService: ObservableObject {
    
    @Published var availableClients: [Client]
    @Published var error: Error? = nil
    
    @ObservedObject var settings: Settings = Settings()
    
    init(availableClients: [Client] = []) {
        self.availableClients = availableClients
    }
    
    /// Call the configuration api of praxisruf to find all available clients for the currently authenticated user.
    /// Loaded clients are published via the availableClients property.
    /// If loading fails an error is published.
    ///
    /// This is called by the ClientSelectView to enable configuration selection.
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
    
    /// Receives the identification of a selected client.
    /// The corresponding client is found in the availableClients property.
    /// The values clientId and name of this client are updated in the settings.
    /// If the selected client does not exist in the availableClients property an error is published.
    ///
    /// This is called by the ClientSelectView to enable confirming the configuration selection.
    func confirm(selection: UUID?) {
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
    }
}
