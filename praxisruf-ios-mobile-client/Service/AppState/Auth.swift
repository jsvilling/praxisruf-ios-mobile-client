//
//  AuthService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation
import SwiftKeychainWrapper

class AuthService : ObservableObject {
    
    @Published var userName: String = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName) ?? "UNKNOWN" {
        didSet {
            KeychainWrapper.standard.set(userName, forKey: UserDefaultKeys.userName)
        }
    }
    
    @Published var isLoggedOut: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var error: Error? = nil
   
    func login(_ username: String, _ password: String) {
        PraxisrufApi().login(username: username, password: password) { result in
            switch result {
                case .success (let token):
                    KeychainWrapper.standard.set(token, forKey: UserDefaultKeys.authToken)
                    KeychainWrapper.standard.set(password, forKey: UserDefaultKeys.password)
                    DispatchQueue.main.async {
                        self.userName = username
                        self.isAuthenticated = true
                        self.isLoggedOut = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
        }
    }
    
    func refresh() {
        guard let username = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName) else {
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.invalidCredential
            }
            return
        }
        
        guard let password = KeychainWrapper.standard.string(forKey: UserDefaultKeys.password) else {
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.invalidCredential
            }
            return
        }
        
        login(username, password)
    }
    
    func logout() {
        RegistrationService().unregister()
        PraxisrufApi().disconnectSignalingService()
        DispatchQueue.main.async {
            Settings.reset()
            self.isAuthenticated = false
            self.isLoggedOut = true
        }
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.authToken)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.userName)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.password)
    }
        
}
