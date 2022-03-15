//
//  RegistrationViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation
import SwiftKeychainWrapper

class RegistrationService: ObservableObject {
    
    let settings = Settings()
    var delegate: RegistrationDelegate? = nil
    
    func register() {
        guard let fcmToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.fcmToken) else {
            print("No fmc token found")
            return
        }
        
        register(messagingToken: fcmToken)
    }
    
    func register(messagingToken: String) {
        KeychainWrapper.standard.set(messagingToken, forKey: UserDefaultKeys.fcmToken)
        PraxisrufApi().register(fcmToken: messagingToken, clientId: settings.clientId) { result in
            switch result {
                case .success(_):
                    print("Registration successful")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func unregister() {
        let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken)
        
        if (authToken == nil) {
            print("Incomplete registration. Cannot unregister with cloud service")
            return
        } else {
            PraxisrufApi().unregister(clientId: settings.clientId) { result in
                switch result {
                    case .success (let response):
                        print(response)
                    case .failure (let error):
                        print(error)
                }
            }
        }

        delegate?.unregister()
    }

}
