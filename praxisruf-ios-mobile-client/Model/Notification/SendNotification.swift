//
//  SendNotification.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 24.10.21.
//

import Foundation

/// This DTO is used to send a Notification via the Cloudservice
/// The concrete Notification is created in the Cloudservice based on the Identifiers sent with this DTO. 
struct SendNotification: Codable {
    
    let notificationTypeId: UUID
    let sender: String
    
}
