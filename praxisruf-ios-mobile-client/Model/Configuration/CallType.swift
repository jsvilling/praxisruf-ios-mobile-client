//
//  CallType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation

struct CallType : Decodable {
    let displayText: String
    let id: String
    let participants: [String]
}
