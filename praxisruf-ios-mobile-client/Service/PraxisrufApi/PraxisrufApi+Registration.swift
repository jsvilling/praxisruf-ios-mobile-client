//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func register(authToken: String, fcmToken: String, clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        post("/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)") { request in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.custom(errorMessage: "Error Response received")))
                    return
                }
                completion(.success("Registration Successful"))
            }.resume()
        }
    }
    
    func unregister(authToken: String, clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        delete("/registrations/(clientId)") { request in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.custom(errorMessage: "Error Response received")))
                    return
                }
                completion(.success("Un-Registration Successful"))
            }.resume()
        }
    }
}
