//
//  CallType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 04.12.21.
//

import Foundation


struct DiesplayCallType: IntercomItem, Hashable, Codable, Identifiable {
    let id: UUID
    let displayText: String
    
    static func compareByDisplayText(_ n1: DiesplayCallType, _ n2: DiesplayCallType) -> Bool {
        return n1.displayText < n2.displayText
    }
}

extension DiesplayCallType {
    static var data = [
        DiesplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DiesplayCallType(id: UUID(), displayText: "Empfang"),
        DiesplayCallType(id: UUID(), displayText: "Steri"),
        DiesplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DiesplayCallType(id: UUID(), displayText: "Empfang"),
        DiesplayCallType(id: UUID(), displayText: "Steri"),
        DiesplayCallType(id: UUID(), displayText: "Alle Zimmer"),
        DiesplayCallType(id: UUID(), displayText: "Empfang"),
        DiesplayCallType(id: UUID(), displayText: "Steri")
    ]
}
