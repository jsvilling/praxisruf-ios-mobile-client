//
//  RegistrationViewModel.swift
//  praxisruf-ios-mobile-client
//
//  This clearly is not a ViewModel.
//  The logic is placed here for now as all the other integration
//  for Praxisruf API is here. This will hav to be reworked !
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

class RegistrationIntegration: ObservableObject {
    
    
    func register() {
        let defaults = UserDefaults.standard
        guard let authToken = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No auth token found")
            return
        }
        
        guard let fcmToken = defaults.string(forKey: UserDefaultKeys.fcmToken) else {
            print("No fmc token found")
            return
        }

        guard let clientId = defaults.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        PraxisrufApi().register(authToken: authToken, fcmToken: fcmToken, clientId: clientId) { result in
            switch result {
                case .success(let msg):
                    print(msg)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
}