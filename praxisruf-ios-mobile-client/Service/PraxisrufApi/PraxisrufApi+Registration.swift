//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func register(fcmToken: String, clientId: String, completion: @escaping (Result<Registration, PraxisrufApiError>) -> Void) {
        post("/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)", completion: completion)
    }
    
    func unregister(clientId: String, completion: @escaping (Result<Nothing, PraxisrufApiError>) -> Void) {
        delete("/registrations/(clientId)", completion: completion)
    }
}
