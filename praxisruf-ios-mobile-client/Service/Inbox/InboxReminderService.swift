//
//  InboxReminderService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 30.11.21.
//

import Foundation
import SwiftUI

class InboxReminderService {

    static func checkInbox() {
        let areAllRead = Inbox.shared.content.isEmpty || Inbox.shared.content.filter { $0.receivedAt <= Date() - 60 } .allSatisfy { $0.ack }
        if (!areAllRead) {
            notifyUnreadItems()
        }
    }
    
    static func notifyUnreadItems() {
        let content = UNMutableNotificationContent()
        content.title = "Neue Nachrichten"
        content.body = "Inbox enthält nicht bestätigte Nachrichten"
        content.categoryIdentifier = "local"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "app_assets_signal_sms.mp3"))
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in }
    }
    
}
