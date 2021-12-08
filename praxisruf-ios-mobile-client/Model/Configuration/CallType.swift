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
    
    static func compareByDisplayText(_ n1: CallType, _ n2: CallType) -> Bool {
        return n1.displayText < n2.displayText
    }
}

extension CallType {
    static var data = [
        CallType(id: UUID(), displayText: "Alle Zimmer"),
        CallType(id: UUID(), displayText: "Empfang"),
        CallType(id: UUID(), displayText: "Steri"),
        CallType(id: UUID(), displayText: "Alle Zimmer"),
        CallType(id: UUID(), displayText: "Empfang"),
        CallType(id: UUID(), displayText: "Steri"),
        CallType(id: UUID(), displayText: "Alle Zimmer"),
        CallType(id: UUID(), displayText: "Empfang"),
        CallType(id: UUID(), displayText: "Steri")
    ]
}
