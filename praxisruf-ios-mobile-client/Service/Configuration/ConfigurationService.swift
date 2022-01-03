//
//  HomeViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation

class ConfigurationService : ObservableObject {
    
    @Published var error: Error? = nil
    @Published var configuration: Configuration = Configuration(notificationTypes: [], callTypes: [])
    
    func loadConfiguration(clientId: String) {        
        PraxisrufApi().getDisplayConfiguration(clientId: clientId) {
            result in
                switch result {
                    case .success(var configuration):
                        DispatchQueue.main.async {
                            configuration.notificationTypes = configuration.notificationTypes.sorted(by: NotificationType.compareByDisplayText)
                            configuration.callTypes = configuration.callTypes.sorted(by: DisplayCallType.compareByDisplayText)
                            self.configuration = configuration
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.error = error
                        }
                }
        }
    }
    
    
}