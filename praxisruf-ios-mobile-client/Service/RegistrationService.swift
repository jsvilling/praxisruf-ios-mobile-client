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
    
    func register() {
        guard let fcmToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.fcmToken) else {
            print("No fmc token found")
            return
        }

        guard let clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        PraxisrufApi().register(fcmToken: fcmToken, clientId: clientId) { result in
            switch result {
                case .success(let msg):
                    print(msg)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func unregister() {
        let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken)
        let clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)
        
        if (authToken == nil || clientId == nil) {
            print("Incomplete registration. Cannot unregister with cloud service")
            return
        } else {
            PraxisrufApi().unregister(clientId: clientId!) { result in
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
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.clientId)
        // The firebase token is not removed. As far as firebase is concerned
        // it belongs to the hardware device. Leaving the stored token here,
        // allows us to re-use it. When the user logs in after a logout, without
        // terminating the app in between. This is fine because the association
        // to the client has already been removed.
    }
    
    private func clearStoredInformation() {
        
    }
    
}
