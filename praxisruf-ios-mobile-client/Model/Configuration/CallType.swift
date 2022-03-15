//
//  CallType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation

/// Represents a call made by pressing a button in the IntercomView
/// A CalLType contains the same information as a DisplayCallType but does additionally contain
/// a list of participants. This list of participants contains the clientIds of that will be
/// targeted when starting a call with a given CallType.
struct CallType : Decodable {
    let displayText: String
    let id: String
    var participants: [String]
}
