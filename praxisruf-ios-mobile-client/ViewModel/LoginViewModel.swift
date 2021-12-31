//
//  LoginViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation
import SwiftKeychainWrapper

class LoginViewModel: ObservableObject {
    
    let settings: Settings = Settings()
    
    var username: String = "admin"
    var password: String = "admin"
    
    @Published var isAuthenticated: Bool = false
    @Published var error: Error? = nil
    
    func login() {
        PraxisrufApi().login(username: username, password: password) { result in
            switch result {
                case .success (let token):
                    KeychainWrapper.standard.set(token, forKey: UserDefaultKeys.authToken)
                    KeychainWrapper.standard.set(self.username, forKey: UserDefaultKeys.userName)
                    KeychainWrapper.standard.set(self.password, forKey: UserDefaultKeys.password)
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.settings.userName = self.username
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
        }
    }
}
