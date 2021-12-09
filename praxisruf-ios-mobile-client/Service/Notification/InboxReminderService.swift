//
//  InboxReminderService.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 30.11.21.
//

import Foundation

class InboxReminderService {

    static func checkInbox() {
        let areAllRead = Inbox.shared.content.isEmpty || Inbox.shared.content.filter { $0.receivedAt <= Date() - 60 } .allSatisfy { $0.ack }
        if (!areAllRead) {
            AudioPlayer.playSystemSound(soundID: 1005)
        }
    }
    
}
