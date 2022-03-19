//
//  Settings.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation
import SwiftKeychainWrapper

/// This service publishes data stored in the userdefaults.
/// It provides accessors and setters for all properties.
/// On set a property is persisted in the userdefaults.
/// The service further provides a method to clear all data stored in the userdefaults.
class Settings : ObservableObject {
    
    @Published var userName: String = storedOrEmptyStringFor(UserDefaultKeys.userName) {
        didSet {
            UserDefaults.standard.set(userName, forKey: UserDefaultKeys.userName)
        }
    }
    
    /// Local settings
    @Published var isSpeechSynthDisabled: Bool = storedOrFalseBoolFor(UserDefaultKeys.isTextToSpeech) {
        didSet {
            UserDefaults.standard.set(isSpeechSynthDisabled, forKey: UserDefaultKeys.isTextToSpeech)
        }
    }
    
    @Published var isIncomingCallsDisabled: Bool = storedOrFalseBoolFor(UserDefaultKeys.isCallsDisabled)  {
        didSet {
            UserDefaults.standard.set(isIncomingCallsDisabled, forKey: UserDefaultKeys.isCallsDisabled)
        }
    }
    
    /// Selected configuration
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
    
    /// Helper methods
    private static func storedOrEmptyStringFor(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    private static func storedOrFalseBoolFor(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    /// Removes all properties for this app from the userdafaults. 
    static func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }    
}
