//
//  CallType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation


struct CallType: IntercomItem, Hashable, Codable, Identifiable {
    let id: UUID
    let displayText: String
    
    static func compareByDisplayText(_ n1: NotificationType, _ n2: NotificationType) -> Bool {
        return n1.displayText < n2.displayText
    }
}
