//
//  PraxisrufApi+Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

/// Extension for PraxisrufApi to make http calls to the configuration domain of the praxisruf api.
///
extension PraxisrufApi {

    /// Retrieves avaibable clients for the logged in user.
    /// Identification of the logged in user will be extracted from the auth token in the cloudservice.
    ///
    /// This is sued by the ConfigurationService to load available clients
    func getAvailableClients(completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        get("/clients/byUser", completion: completion)
    }
    
    /// Retrieves the configuration for the IntercomView.
    /// This contains all data for notification and call buttons.
    ///
    /// This is called by the ConfigurationService.
    func getDisplayConfiguration(clientId: String, completion: @escaping (Result<Configuration, PraxisrufApiError>) -> Void) {
        get("/configurations/types?clientId=\(clientId)", completion: completion)
    }
    
    /// Retrieves the participants of a given call button.
    ///
    /// This is used by the CallService to initiate a call.
    func getCallTypeParticipants(callTypeId: String, completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        get("/calltypes/\(callTypeId)/participants", completion: completion)
    }
}
