//
//  HomeViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation

/// A ClientConfiguration represents the configuration of a Device in Praxisruf.
/// This service allows loading the configuration of a selected client from the configuration api of praxisruf.
/// The service provides properties to publish loaded configurations and errors during loading of a configuration.
class ConfigurationService : ObservableObject {
    
    @Published var error: Error? = nil
    @Published var configuration: Configuration = Configuration(notificationTypes: [], callTypes: [])
    
    /// Calls the praxisruf configuration api to retrieve the ClientConfiguration with the given id.
    /// A loaded ClinetConfiguration is published via the configuration porperty.
    /// Any errors during loading are published via the error property. 
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
