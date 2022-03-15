//
//  NotificationSendResult.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 28.11.21.
//

import Foundation

/// This DTO represents the response of the Cloudservice after a SendNotification was sent.
/// It contains the ID of the created Notification and a flag whether all sends were successful.
/// This is used in the NotifictionService to request retries from the user, if the sending failed. 
struct NotificationSendResult: Codable{
    
    var notificationId: UUID
    var allSuccess: Bool
    
}
