//
//  PraxisApi+Notification.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

/// Extension of PraxisrufApi which enables sending notifications over the notification domain of the cloudservice api.
extension PraxisrufApi {
    
    /// Sends the given notification via the notification api.
    ///
    /// This is called by the NotificationService
    func sendNotification(sendNotification: SendNotification, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        let body = try? JSONEncoder().encode(sendNotification)
        post("/notifications", body: body, completion: completion)
    }
    
    /// Retries the notification with the given id by requesting a retry via the notification api.
    ///
    /// This is called by the NotificationService. 
    func retryNotification(notificationId: UUID, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        post("/notifications?notificationId=\(notificationId.uuidString)", completion: completion)
    }
}
