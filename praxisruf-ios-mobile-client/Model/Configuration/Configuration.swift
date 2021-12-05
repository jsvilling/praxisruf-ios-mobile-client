//
//  Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation

struct Configuration : Hashable, Codable {
    var notificationTypes: [NotificationType]
    var callTypes: [CallType]
}

extension Configuration {
    static var data = Configuration(notificationTypes: NotificationType.data, callTypes: [])
}
