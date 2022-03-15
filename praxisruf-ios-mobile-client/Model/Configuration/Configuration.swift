//
//  Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation

/// This DTO represents the current client configuration
/// It contains the notificationTypes and callTypes that are used to display
/// buttons on the IntercomView. 
struct Configuration : Hashable, Codable {
    var notificationTypes: [NotificationType]
    var callTypes: [DisplayCallType]
}

extension Configuration {
    static var data = Configuration(notificationTypes: NotificationType.data, callTypes: DisplayCallType.data)
}
