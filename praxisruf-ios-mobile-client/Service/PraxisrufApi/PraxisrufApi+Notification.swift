//
//  PraxisApi+Notification.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func sendNotification(authToken: String, sendNotification: SendNotification, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        
        guard let url = URL(string: "\(baseUrlValue)/notifications/send") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(sendNotification)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.custom(errorMessage: "Error sending notification")))
                return
            }
            completion(.success("Notification was sent"))
        }.resume()
    }
    
}
