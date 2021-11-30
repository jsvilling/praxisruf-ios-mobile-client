//
//  SettingsViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation

class SettingsViewModel : ObservableObject {
    
    @Published var isLoggedOut: Bool = false
    
    func logout() {
        RegistrationService().unregister()
        DispatchQueue.main.async {
            self.isLoggedOut = true
        }
    }
    
}
