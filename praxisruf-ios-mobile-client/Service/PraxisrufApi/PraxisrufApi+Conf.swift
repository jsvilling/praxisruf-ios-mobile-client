//
//  PraxisrufApi+Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

extension PraxisrufApi {

    func getAvailableClients(completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        
        get("/clients/byUser") { request in
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
    
    func getDisplayConfiguration(clientId: String, completion: @escaping (Result<Configuration, PraxisrufApiError>) -> Void) {
        get("/configurations/types?clientId=\(clientId)") { request in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.custom(errorMessage: "Error Response received")))
                    return
                }

                guard let responsData = data else {
                     return
                 }
                
                guard let clients = try? JSONDecoder().decode(Configuration.self, from: responsData) else {
                    completion(.failure(.custom(errorMessage: "Invalid Data")))
                    return
                }

                completion(.success(clients))
            }.resume()
        }
    }
    
    func getRelevantNotificationTypes(clientId: String, completion: @escaping (Result<[NotificationType], PraxisrufApiError>) -> Void) {
        get("/notificationtypes/search?clientId=\(clientId)") { request in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.custom(errorMessage: "Error Response received")))
                    return
                }

                guard let responsData = data else {
                     completion(.success([]))
                     return
                 }
                
                guard let clients = try? JSONDecoder().decode([NotificationType].self, from: responsData) else {
                    completion(.failure(.custom(errorMessage: "Invalid Data")))
                    return
                }

                completion(.success(clients))
            }.resume()
        }
    }
}
