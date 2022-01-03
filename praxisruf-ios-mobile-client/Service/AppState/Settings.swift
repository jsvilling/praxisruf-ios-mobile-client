//
//  Settings.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation
import SwiftKeychainWrapper

class Settings : ObservableObject {
    
    private init() {}
    
    @Published var userName: String = storedOrEmptyStringFor(SettingsKeys.userName) {
        didSet {
            UserDefaults.standard.set(userName, forKey: SettingsKeys.userName)
        }
    }
    
    @Published var isSpeechSynthEnabled: Bool = storedOrFalseBoolFor(SettingsKeys.isTextToSpeech) {
        didSet {
            UserDefaults.standard.set(isSpeechSynthEnabled, forKey: SettingsKeys.isTextToSpeech)
        }
    }
    
    @Published var isIncomingCallsDisabled: Bool = storedOrFalseBoolFor(SettingsKeys.isCallsDisabled)  {
        didSet {
            UserDefaults.standard.set(isIncomingCallsDisabled, forKey: SettingsKeys.isCallsDisabled)
        }
    }
    
    @Published var clientId: String = storedOrEmptyStringFor(SettingsKeys.clientId) {
        didSet {
            UserDefaults.standard.set(clientId, forKey: SettingsKeys.clientId)
        }
    }
    
    @Published var clientName = storedOrEmptyStringFor(SettingsKeys.clientName) {
        didSet {
            UserDefaults.standard.set(clientName, forKey: SettingsKeys.clientName)
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
        
        // The firebase token is not removed. As far as firebase is concerned
        // it belongs to the hardware device. Leaving the stored token here,
        // allows us to re-use it. When the user logs in after a logout, without
        // terminating the app in between. This is fine because the association
        // to the client has already been removed.
    }
    
    struct SettingsKeys {
        static let clientName: String = "clientName"
        static let clientId: String = "clientId"
        
        static let fcmToken: String = "fcmToken"
        
        static let userName: String = "userName"
        static let password: String = "password"
        
        static let isTextToSpeech: String = "isTextToSpeech"
        static let isCallsDisabled: String = "isCallsEnabled"
    }
}

extension Settings {
    static let standard = Settings()
}
