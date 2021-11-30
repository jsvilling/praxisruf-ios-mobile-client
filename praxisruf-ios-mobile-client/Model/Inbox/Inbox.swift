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
    
    func receiveNofication(title: String, body: String, sender: String) {
        let notification = InboxItem(type: "mail", title: title, body: body, sender: sender)
        DispatchQueue.main.async {
            self.content.append(notification)
        }
    }
}

extension Inbox {
    static let shared = Inbox()
}
