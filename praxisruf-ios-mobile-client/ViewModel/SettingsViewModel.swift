//
//  SettingsViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation
import SwiftKeychainWrapper

class SettingsViewModel : ObservableObject {
    
    @Published var isLoggedOut: Bool = false
    @Published var isSpeechSynthEnabled: Bool = true
    @Published var isIncomingCallsEnabled: Bool = true
    
    @Published var userName = ""
    @Published var clientName = ""
    
    init() {
        load()
    }
    
    func load() {
        isSpeechSynthEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.isTextToSpeech)
        isIncomingCallsEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.isCallsEnabled)
        
        userName = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName) ?? ""
        clientName = UserDefaults.standard.string(forKey: UserDefaultKeys.clientName) ?? ""
    }
    
    func save() {
        UserDefaults.standard.set(isSpeechSynthEnabled, forKey: UserDefaultKeys.isTextToSpeech)
        UserDefaults.standard.set(isIncomingCallsEnabled, forKey: UserDefaultKeys.isCallsEnabled)
    }
    
    func logout() {
        RegistrationService().unregister()
        PraxisrufApi().disconnectSignalingService()
        DispatchQueue.main.async {
            self.isLoggedOut = true
        }
    }
    
}
