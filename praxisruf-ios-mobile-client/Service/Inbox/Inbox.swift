//
//  NotificationInbox.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

/// This service allows to collect all received InboxItems
/// It is used by the InboxView to display InboxItems
/// and by InboxReminderService to display reminders for unread notifications.
///
/// The service provides methods for registering call and notification items
/// as well as a method to clear the inbox content.
class Inbox: ObservableObject {
    
    @Published var content = [InboxItem]()
    
    init(values: [InboxItem] = []) {
        self.content = values
    }
    
    /// Adds an InboxItem to the Inbox based on a received notification
    func receive(_ notification: ReceiveNotification) {
        let notification = InboxItem(type: "mail", title: notification.title, body: notification.body, sender: notification.sender)
        DispatchQueue.main.async {
            self.content.insert(notification, at: 0)
        }
    }
    
    /// Adds an InboxItem to the Inbox based on an incoming notification
    func receiveCall(_ signal: Signal) {
        let call = InboxItem(type: "phone.fill.arrow.down.left", body: "Empfangener Anruf", ack: true, sender: signal.description)
        DispatchQueue.main.async {
            self.content.insert(call, at: 0)
        }
    }
    
    ///Adds an InboxItem to the Inbox based on a signal for a declined call
    func receiveDeclinedCall(_ signal: Signal) {
        let call = InboxItem(type: "phone.arrow.down.left", body: "Abgelehnter Anruf", ack: false, sender: signal.description)
        DispatchQueue.main.async {
            self.content.insert(call, at: 0)
        }
    }
    
    /// Removes all items from the Inbox content
    func clear() {
        content.removeAll()
    }
}


