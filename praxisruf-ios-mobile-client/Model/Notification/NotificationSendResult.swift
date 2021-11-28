//
//  NotificationSendResult.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation

struct NotificationSendResult: Codable{
    
    let notificationId: UUID
    let allSuccess: Bool
    
}
