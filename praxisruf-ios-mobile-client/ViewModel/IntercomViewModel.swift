//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class IntercomViewModel: ObservableObject {
    
    @Published var notificationTypes: [NotificationType]
    
    init(notificationTypes: [NotificationType] = []) {
        self.notificationTypes = notificationTypes
    }
    
    func getNotificationTypes() {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: "jwt") else {
            print("No token found")
            return
        }

        guard let clientId = defaults.string(forKey: "clientId") else {
            print("No clientId found")
            return
        }
        
        PraxisrufApi().getRelevantNotificationTypes(clientId: clientId, token: token) { result in
            switch result {
                case .success(let notificationTypes):
                    DispatchQueue.main.async {
                        self.notificationTypes = notificationTypes
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
    }
    
}
