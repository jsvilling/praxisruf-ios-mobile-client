//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func register(authToken: String, fcmToken: String, clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        authorizedRequest("/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)") { r in
            var request = r
            request.httpMethod = "POST"
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
        authorizedRequest("/registrations/(clientId)") { r in
            var request = r
            request.httpMethod = "DELETE"
            
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
