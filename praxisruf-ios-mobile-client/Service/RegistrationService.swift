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

class RegistrationService: ObservableObject {
    
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
    
    func unregister() {
        let defaults = UserDefaults.standard
        let authToken = defaults.string(forKey: UserDefaultKeys.authToken)
        let clientId = defaults.string(forKey: UserDefaultKeys.clientId)
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.authToken)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.clientId)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userName)
        
        if (authToken == nil || clientId == nil) {
            print("Incomplete registration. Cannot unregister with cloud service")
            return
        }
        
        PraxisrufApi().unregister(authToken: authToken!, clientId: clientId!) { result in
            switch result {
                case .success (let response):
                    print(response)
                case .failure (let error):
                    print(error)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.authToken)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.clientId)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userName)
        // The firebase token is not removed. As far as firebase is concerned
        // it belongs to the hardware device. Leaving the stored token here,
        // allows us to re-use it. When the user logs in after a logout, without
        // terminating the app in between. This is fine because the association
        // to the client has already been removed.
    }
    
}
