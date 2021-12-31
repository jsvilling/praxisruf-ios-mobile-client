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
import SwiftKeychainWrapper

class RegistrationService: ObservableObject {
    
    let settings = Settings()
    
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

        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.authToken)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.userName)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.password)
      
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // The firebase token is not removed. As far as firebase is concerned
        // it belongs to the hardware device. Leaving the stored token here,
        // allows us to re-use it. When the user logs in after a logout, without
        // terminating the app in between. This is fine because the association
        // to the client has already been removed.
    }

}
