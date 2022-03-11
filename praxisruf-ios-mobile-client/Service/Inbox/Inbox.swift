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
    
    func receiveCall(_ signal: Signal) {
        let call = InboxItem(type: "phone.fill.arrow.down.left", body: "Empfangener Anruf", ack: true, sender: signal.description)
        DispatchQueue.main.async {
            self.content.append(call)
        }
    }
    
    func receiveDeclinedCall(_ signal: Signal) {
        let call = InboxItem(type: "phone.arrow.down.left", body: "Abgelehnter Anruf", ack: false, sender: signal.description)
        DispatchQueue.main.async {
            self.content.append(call)
        }
    }
    
    func clear() {
        content.removeAll()
    }
}

extension Inbox {
    static let shared = Inbox()
}