//
//  ConfSelectViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class ClientSelectViewModel: ObservableObject {
    
    @Published var availableClients: [Client]
    
    init(availableClients: [Client] = []) {
        self.availableClients = availableClients
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
}
