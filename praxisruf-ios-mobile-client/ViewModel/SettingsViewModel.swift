//
//  SettingsViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation

class SettingsViewModel : ObservableObject {
    
    @Published var isLoggedOut: Bool = false
    @Published var isSpeechSynthEnabled: Bool = true
    @Published var isIncomingCallsEnabled: Bool = true
    
    func load() {
        isSpeechSynthEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.isTextToSpeech)
        isIncomingCallsEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.isCallsEnabled)
    }
    
    func save() {
        UserDefaults.standard.set(isSpeechSynthEnabled, forKey: UserDefaultKeys.isTextToSpeech)
        UserDefaults.standard.set(isIncomingCallsEnabled, forKey: UserDefaultKeys.isCallsEnabled)
    }
    
    func logout() {
        RegistrationService().unregister()
        DispatchQueue.main.async {
            self.isLoggedOut = true
        }
    }
    
}
