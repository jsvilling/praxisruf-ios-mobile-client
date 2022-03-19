//
//  RegistrationViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation
import SwiftKeychainWrapper

/// This service allows registering and unregistering for notifications with praxisruf.
class RegistrationService: ObservableObject {
    
    let settings = Settings()
    var delegate: RegistrationDelegate? = nil
    
    /// Finds the firebase cloud messaging token in the keychain and registers it with the cloudservice.
    func register() {
        guard let fcmToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.fcmToken) else {
            print("No fmc token found")
            return
        }
        
        register(messagingToken: fcmToken)
    }
    
    /// Registers the given string as firebase cloud messaging token with the cloudservice.
    /// The given token is also saved to the keychain for later reuse.
    func register(messagingToken: String) {
        KeychainWrapper.standard.set(messagingToken, forKey: UserDefaultKeys.fcmToken)
        PraxisrufApi().register(fcmToken: messagingToken, clientId: settings.clientId) { result in
            switch result {
                case .success(_):
                    print("Registration successful")
                case .failure(let error):
                    print(error.localizedDescription ?? "Registration failed")
            }
        }
    }
    
    /// Clears any saved firebase messaging token from the keychain and notifies the cloudservice, that the device will no longer receive notifications for its registration.
    /// Additionally the RegistrationDelegate is called to unregister the client with firebase cloud messaging.
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
