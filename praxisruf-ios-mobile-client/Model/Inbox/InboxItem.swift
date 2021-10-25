//
//  InboxItem.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

struct InboxItem: Identifiable {
    var id: UUID = UUID()
    var type: String
    var title: String
    var body: String
    var ack: Bool = false
    var receivedAt = Date()
}

extension InboxItem {
        static var data: [InboxItem] = [
            InboxItem(type: "phone", title: "Alarm", body: "Ganz üble Sache"),
            InboxItem(type: "mail", title: "Zahnpasta", body: "Zahnpasta"),
            InboxItem(type: "phone", title: "Alarm", body: "Alarm", ack: true),
            InboxItem(type: "mail", title: "Zahnpasta", body: "Zahnpasta", ack: true)
        ]
}
