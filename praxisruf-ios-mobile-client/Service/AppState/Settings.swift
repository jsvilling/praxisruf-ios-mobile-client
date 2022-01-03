//
//  Settings.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation
import SwiftKeychainWrapper

class Settings : ObservableObject {
    
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
    
    private static func storedOrEmptyStringFor(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    private static func storedOrFalseBoolFor(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }    
}
