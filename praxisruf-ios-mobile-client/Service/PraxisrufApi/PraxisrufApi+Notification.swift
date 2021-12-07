//
//  PraxisApi+Notification.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

extension PraxisrufApi {
    
    func sendNotification(sendNotification: SendNotification, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        let body = try? JSONEncoder().encode(sendNotification)
        post("/notifications/send", body: body, completion: completion)
    }
    
    func retryNotification(notificationId: UUID, completion: @escaping (Result<NotificationSendResult, PraxisrufApiError>) -> Void) {
        post("/notifications/retry?notificationId=\(notificationId.uuidString)", completion: completion)
    }
}
