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
    var title: String = ""
    var body: String = ""
    var ack: Bool = false
    var receivedAt = Date()
    var sender: String
    
    func fullBody() -> String {
        if (title != "") {
            return "\(title) - \(body)"
        }
        return body
    }
}

extension InboxItem {
        static var data: [InboxItem] = [
            InboxItem(type: "phone", title: "", body: "", sender: "Behandlungszimmer 1"),
            InboxItem(type: "mail", title: "Zahnpasta", body: "Zahnpasta", sender: "Empfang"),
            InboxItem(type: "phone", title: "", body: "", ack: true, sender: "Benhandlungszimmer 1"),
            InboxItem(type: "mail", title: "Zahnpasta", body: "Zahnpasta", ack: true, sender: "Empfang")
        ]
}
