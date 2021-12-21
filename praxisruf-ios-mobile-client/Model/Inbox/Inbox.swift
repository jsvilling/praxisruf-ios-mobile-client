//
//  NotificationInbox.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

class Inbox: ObservableObject {
    
    @Published var content = [InboxItem]()
    
    init(values: [InboxItem] = []) {
        self.content = values
    }
    
    func receive(_ notification: ReceiveNotification) {
        let notification = InboxItem(type: "mail", title: notification.title, body: notification.body, sender: notification.sender)
        DispatchQueue.main.async {
            self.content.append(notification)
        }
    }
    
    func receive(_ signal: Signal) {
        let call = InboxItem(type: "phone.arrow.down.left", body: "Received Call", ack: true, sender: signal.description)
        DispatchQueue.main.async {
            self.content.append(call)
        }
    }
}

extension Inbox {
    static let shared = Inbox()
}
