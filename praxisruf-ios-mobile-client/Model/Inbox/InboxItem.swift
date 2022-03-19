//
//  InboxItem.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

/// Represents an entry stored in the Inbox service and displayed in the InboxView
/// This can either be a received notification a past call
struct InboxItem: Identifiable {
    var id: UUID = UUID()
    var type: String
    var title: String = ""
    var body: String = ""
    var ack: Bool = false
    var receivedAt = Date()
    var sender: String
    
    /// Constructs the display text for a InboxItem
    func fullBody() -> String {
        if (title == "") {
            return body
        }
        if (body == "") {
            return title
        }
        return "\(title) - \(body)"
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
