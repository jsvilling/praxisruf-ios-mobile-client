//
//  IntercomItem.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 23.10.21.
//

import Foundation

/// Represents a CallType which is displayed as a button in the intercom view
protocol IntercomItem {
    var id: UUID { get }
    var displayText: String { get }
}
