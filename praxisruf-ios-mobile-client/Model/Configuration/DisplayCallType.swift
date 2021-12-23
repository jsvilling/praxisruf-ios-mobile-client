//
//  CallType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation


struct DisplayCallType: IntercomItem, Hashable, Codable, Identifiable {
    let id: UUID
    let displayText: String
    
    static func compareByDisplayText(_ n1: DisplayCallType, _ n2: DisplayCallType) -> Bool {
        return n1.displayText < n2.displayText
    }
}

extension DisplayCallType {
    static var data = [
        DisplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DisplayCallType(id: UUID(), displayText: "Empfang"),
        DisplayCallType(id: UUID(), displayText: "Steri"),
        DisplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DisplayCallType(id: UUID(), displayText: "Empfang"),
        DisplayCallType(id: UUID(), displayText: "Steri"),
        DisplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DisplayCallType(id: UUID(), displayText: "Empfang"),
        DisplayCallType(id: UUID(), displayText: "Steri")
    ]
}
