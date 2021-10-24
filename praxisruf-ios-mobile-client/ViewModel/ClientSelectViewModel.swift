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
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No token found")
            return
        }
        
        PraxisrufApi().getAvailableClients(token: token) { result in
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
