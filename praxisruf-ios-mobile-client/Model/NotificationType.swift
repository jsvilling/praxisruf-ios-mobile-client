//
//  NotificationType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

struct NotificationType: IntercomItem, Hashable, Codable, Identifiable {
    let id: UUID
    let displayText: String
    let title: String
    let body: String
    let description: String
}


extension NotificationType {
    static var data: [NotificationType] = [
        NotificationType(id: UUID(), displayText: "Alarm", title: "Alarm", body: "Alarm", description: "Button triggers urgent alarm"),
        NotificationType(id: UUID(), displayText: "Zahnpasta", title: "Zahnpasta", body: "Zahnpasta", description: "Button requests Zahnpasta")
    ]
}

