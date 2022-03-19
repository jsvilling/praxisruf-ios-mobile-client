//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

/// Extension of PraxisrufApi which enables registering and unregistering for notifications in the configuration domain of the cloudservice api.
extension PraxisrufApi {
    
    /// Registers the given firebase cloud messaging token for the given clientId in the cloudservice
    ///
    /// This is called by the AppDelegate upon receiving a new token.
    /// It is called again upon loading of HomeView to enuser the registration is up to date after reactivating the app.
    func register(fcmToken: String, clientId: String, completion: @escaping (Result<Registration, PraxisrufApiError>) -> Void) {
        post("/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)", completion: completion)
    }
    
    /// Unregisters all registrations of the given clientId.
    ///
    /// This is called in the RegistratinoService when unregistering for notifications
    func unregister(clientId: String, completion: @escaping (Result<Nothing, PraxisrufApiError>) -> Void) {
        delete("/registrations/\(clientId)", completion: completion)
    }
}
