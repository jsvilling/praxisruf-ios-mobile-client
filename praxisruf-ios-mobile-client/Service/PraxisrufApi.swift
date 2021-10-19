//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation

class PraxisrufApi : ObservableObject {
    
    enum ApiError: Error {
        case invalidCredentials
        case custom(errorMessage: String)
    }
        
    let baseUrlValue = "https://www.praxisruf.ch/api"
    
    func login(username: String, password: String, completion: @escaping (Result<String, ApiError>) -> Void) {
        print("Logging in with: \(username) \(password)")
        guard let url = URL(string: "\(baseUrlValue)/users/login") else {
            print("Invalid url")
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
