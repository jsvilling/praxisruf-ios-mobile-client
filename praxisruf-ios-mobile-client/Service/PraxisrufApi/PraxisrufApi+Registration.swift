//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func register(fcmToken: String, clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        //TODO: Fix registration endpoint and return registration after creation
        post("/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)", completion: completion)
    }
    
    func unregister(clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        delete("/registrations/(clientId)", completion: completion)
    }
}
