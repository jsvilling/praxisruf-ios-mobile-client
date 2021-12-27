//
//  Settings.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation
import SwiftKeychainWrapper

class Settings : ObservableObject {
    
    @Published var isLoggedOut: Bool = false
    
    @Published var userName: String = storedOrEmptyStringFor(UserDefaultKeys.userName) {
        didSet {
            UserDefaults.standard.set(userName, forKey: UserDefaultKeys.userName)
        }
    }
    
    @Published var isSpeechSynthEnabled: Bool = storedOrFalseBoolFor(UserDefaultKeys.isTextToSpeech) {
        didSet {
            UserDefaults.standard.set(isSpeechSynthEnabled, forKey: UserDefaultKeys.isTextToSpeech)
        }
    }
    
    @Published var isIncomingCallsDisabled: Bool = storedOrFalseBoolFor(UserDefaultKeys.isCallsDisabled)  {
        didSet {
            UserDefaults.standard.set(isIncomingCallsDisabled, forKey: UserDefaultKeys.isCallsDisabled)
        }
    }
    
    @Published var clientId: String = storedOrEmptyStringFor(UserDefaultKeys.clientId) {
        didSet {
            UserDefaults.standard.set(clientId, forKey: UserDefaultKeys.clientId)
        }
    }
    
    @Published var clientName = storedOrEmptyStringFor(UserDefaultKeys.clientName) {
        didSet {
            UserDefaults.standard.set(clientName, forKey: UserDefaultKeys.clientName)
        }
    }
    
    static func storedOrEmptyStringFor(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    static func storedOrFalseBoolFor(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    func logout() {
        RegistrationService().unregister()
        PraxisrufApi().disconnectSignalingService()
        DispatchQueue.main.async {
            self.isLoggedOut = true
        }
    }
    
}
