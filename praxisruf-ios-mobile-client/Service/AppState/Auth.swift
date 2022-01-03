//
//  AuthService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation
import SwiftKeychainWrapper

class AuthService : ObservableObject {
    
    let settings: Settings = Settings()
        
    @Published var isAuthenticated: Bool = false
    @Published var error: Error? = nil
    
    @Published var authToken: String? = KeychainWrapper.standard.string(forKey: AuthKeys.authToken) {
        didSet {
            KeychainWrapper.standard.set(authToken!, forKey: AuthKeys.authToken)
        }
    }
    
    @Published var messagingToken: String? = KeychainWrapper.standard.string(forKey: AuthKeys.messagingToken) {
        didSet {
            KeychainWrapper.standard.set(messagingToken!, forKey: AuthKeys.messagingToken)
        }
    }
    
    func login(_ username: String, _ password: String) {
        PraxisrufApi().login(username: username, password: password) { result in
            switch result {
                case .success (let token):
                    KeychainWrapper.standard.set(token, forKey: AuthKeys.authToken)
                    KeychainWrapper.standard.set(username, forKey: AuthKeys.userName)
                    KeychainWrapper.standard.set(password, forKey: AuthKeys.password)
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.settings.userName = username
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
        }
    }
    
    func refresh() {
        guard let username = KeychainWrapper.standard.string(forKey: AuthKeys.userName) else {
            DispatchQueue.main.async {
                self.error = PraxisrufApiError.invalidCredential
            }
            return
        }
        
        guard let password = KeychainWrapper.standard.string(forKey: AuthKeys.password) else {
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
        }
        KeychainWrapper.standard.removeObject(forKey: AuthKeys.authToken)
        KeychainWrapper.standard.removeObject(forKey: AuthKeys.userName)
        KeychainWrapper.standard.removeObject(forKey: AuthKeys.password)
    }
        
    
    struct AuthKeys {
        static let authToken: String = "authToken"
        static let messagingToken: String = "fcmToken"
        static let userName: String = "userName"
        static let password: String = "password"
    }
}
