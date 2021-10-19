//
//  PraxisrufApi+Auth.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 19.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func login(username: String, password: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)/users/login") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }

        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.custom(errorMessage: "Error Response received")))
                return
            }
            
            guard let token = httpResponse.value(forHTTPHeaderField: "Authorization") else {
                completion(.failure(.custom(errorMessage: "No token received")))
                return
            }
            
            completion(.success(token))

        }.resume()
    }
}
