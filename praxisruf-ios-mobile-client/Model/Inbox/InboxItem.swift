//
//  InboxItem.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

struct InboxItem: Identifiable {
    var id: UUID
    var type: String
    var title: String
    var body: String
    var ack: Bool
}

extension InboxItem {
        static var data: [InboxItem] = [
            InboxItem(id: UUID(), type: "phone", title: "Alarm", body: "Ganz üble Sache", ack: false),
            InboxItem(id: UUID(), type: "mail", title: "Zahnpasta", body: "Zahnpasta", ack: false),
            InboxItem(id: UUID(), type: "phone", title: "Alarm", body: "Alarm", ack: true),
            InboxItem(id: UUID(), type: "mail", title: "Zahnpasta", body: "Zahnpasta", ack: true)
        ]
}
