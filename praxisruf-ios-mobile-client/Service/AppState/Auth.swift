//
//  AuthService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation
import SwiftKeychainWrapper

/// This service provides a means to manage the authentication state of a user.
///
/// It publishes properties for userName, authenticationState and authentication related errors.
/// It provides methods to login, logout and refresh auth tokens.
/// On login all auth data is stored in the keystore.
/// On logout all auth data is removed from the keystore.
class AuthService : ObservableObject {
    
    @Published var userName: String = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName) ?? "UNKNOWN" {
        didSet {
            KeychainWrapper.standard.set(userName, forKey: UserDefaultKeys.userName)
        }
    }

    @Published var isAuthenticated: Bool = false
    @Published var error: Error? = nil
   
    /// Logs in a user with the given basic auth credentials.
    /// This is done by using the PraxisrufApi service to send a login request to the cloudservice.
    /// If the request is successful username, password and the received auth token will be stored in the keystore.
    /// If the request fails, an error is published.
    func login(_ username: String, _ password: String) {
        PraxisrufApi().login(username: username, password: password) { result in
            switch result {
                case .success (let token):
                    KeychainWrapper.standard.set(token, forKey: UserDefaultKeys.authToken)
                    KeychainWrapper.standard.set(password, forKey: UserDefaultKeys.password)
                    DispatchQueue.main.async {
                        self.userName = username
                        self.isAuthenticated = true
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
        }
    }
    
    /// Refreshes the jwt auth token for cloudservice requests.
    /// This is done by sending a basic auth request with the credentials stored in the keystore.
    /// If the request is successful the keystoredata will be refreshed with the new data.
    /// If the request fails or no credentials were stored in the keystore an error is published.
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
    
    /// Logs a user out
    /// This includes unregistering with FirebaseCloudMessaging and the signaling instance.
    /// It also includes clearing all local settings, inboxdata as well as data stored in the keystore and userdefaults. 
    func logout() {
        RegistrationService().unregister()
        PraxisrufApi().disconnectSignalingService()
        DispatchQueue.main.async {
            Settings.reset()
            Inbox.shared.clear()
            self.isAuthenticated = false
        }
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.authToken)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.userName)
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKeys.password)
    }
        
}
