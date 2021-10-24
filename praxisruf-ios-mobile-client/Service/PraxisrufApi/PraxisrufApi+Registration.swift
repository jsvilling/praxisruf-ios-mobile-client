//
//  PraxisrufApi+Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func register(authToken: String, fcmToken: String, clientId: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)/registrations?clientId=\(clientId)&fcmToken=\(fcmToken)") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.custom(errorMessage: "Error Response received")))
                return
            }
            completion(.success("Registration Successful"))
        }.resume()
    }
    
    func unregister(authToken: String, fcmToken: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        print("Unregister called for ")
    }
}
