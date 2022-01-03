//
//  RegistrationViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation
import SwiftKeychainWrapper

protocol RegistrationDelegate {
    func unregister()
}

class RegistrationService: ObservableObject {
    
    var delegate: RegistrationDelegate? = nil
    
    func register() {
        guard let messagingToken = AuthService().messagingToken else {
            print("No messagingToken found")
            return
        }
        
        register(messagingToken: messagingToken)
    }
    
    func register(messagingToken: String) {
        AuthService().messagingToken = messagingToken
        PraxisrufApi().register(fcmToken: messagingToken, clientId: Settings().clientId) { result in
            switch result {
                case .success(_):
                    print("Registration successful")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func unregister() {
        let authToken = AuthService().authToken
        
        if (authToken == nil) {
            print("Incomplete registration. Cannot unregister with cloud service")
            return
        } else {
            PraxisrufApi().unregister(clientId: Settings().clientId) { result in
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
