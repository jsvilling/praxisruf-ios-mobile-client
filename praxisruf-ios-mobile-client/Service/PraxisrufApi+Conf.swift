//
//  PraxisrufApi+Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation


extension PraxisrufApi {

    func getAvailableClients(token: String, completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)/clients/byUser") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.custom(errorMessage: "Error Response received")))
                return
            }
            
            guard let responsData = data else {
                 completion(.success([]))
                 return
             }
            
            guard let clients = try? JSONDecoder().decode([Client].self, from: responsData) else {
                completion(.failure(.custom(errorMessage: "Invalid Data")))
                return
            }

            completion(.success(clients))
        }.resume()
    }
}
    

