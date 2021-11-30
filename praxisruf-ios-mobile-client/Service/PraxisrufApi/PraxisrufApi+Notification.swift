//
//  PraxisApi+Notification.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func sendNotification(sendNotification: SendNotification, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        post("/notifications/send") { r in
            var request = r
            request.httpBody = try? JSONEncoder().encode(sendNotification)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.custom(errorMessage: "Error sending notification")))
                    return
                }
                
                guard let responsData = data else {
                     print("Critical error when sending notification")
                     return
                 }
                
                guard let notificationSendResponse = try? JSONDecoder().decode(NotificationSendResult.self, from: responsData) else {
                    completion(.failure(.custom(errorMessage: "Invalid Data")))
                    return
                }

                completion(.success(notificationSendResponse))
            }.resume()
        }
    }
    
    func retryNotification(notificationId: UUID, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        post("/notifications/retry?clientId=\(notificationId.uuidString)") { r in
            var request = r
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {

                    completion(.failure(.custom(errorMessage: "Error sending notification")))
                    return
                }
                
                guard let responsData = data else {
                     print("Critical error when sending notification")
                     return
                 }
                
                guard let notificationSendResponse = try? JSONDecoder().decode(NotificationSendResult.self, from: responsData) else {
                    completion(.failure(.custom(errorMessage: "Invalid Data")))
                    return
                }
                
                completion(.success(notificationSendResponse))
            }.resume()
        }
    }
}
