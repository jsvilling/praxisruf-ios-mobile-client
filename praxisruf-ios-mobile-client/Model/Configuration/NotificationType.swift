//
//  NotificationType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//
import Foundation

/// Represents a button on the IntercomView that is used to stend a notification.
struct NotificationType: IntercomItem, Hashable, Codable, Identifiable {
    let id: UUID
    let displayText: String
    let title: String
    let body: String?
    let description: String?
    
    static func compareByDisplayText(_ n1: NotificationType, _ n2: NotificationType) -> Bool {
        return n1.displayText < n2.displayText
    }
}

extension NotificationType {
    static var data: [NotificationType] = [
        NotificationType(id: UUID(), displayText: "Alarm", title: "Alarm", body: "Alarm", description: "Button triggers urgent alarm"),
        NotificationType(id: UUID(), displayText: "Zahnpasta", title: "Zahnpasta", body: "Zahnpasta", description: "Button requests Zahnpasta"),
        NotificationType(id: UUID(), displayText: "Nächster Patient", title: "Nächster Patient", body: "Nächster Patient", description: "Nächster Patient"),
        NotificationType(id: UUID(), displayText: "Alarm", title: "Alarm", body: "Alarm", description: "Button triggers urgent alarm"),
        NotificationType(id: UUID(), displayText: "Zahnpasta", title: "Zahnpasta", body: "Zahnpasta", description: "Button requests Zahnpasta"),
        NotificationType(id: UUID(), displayText: "Nächster Patient", title: "Nächster Patient", body: "Nächster Patient", description: "Nächster Patient"),
        NotificationType(id: UUID(), displayText: "Alarm", title: "Alarm", body: "Alarm", description: "Button triggers urgent alarm"),
        NotificationType(id: UUID(), displayText: "Zahnpasta", title: "Zahnpasta", body: "Zahnpasta", description: "Button requests Zahnpasta"),
        NotificationType(id: UUID(), displayText: "Nächster Patient", title: "Nächster Patient", body: "Nächster Patient", description: "Nächster Patient")
    ]
}
