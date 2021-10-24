//
//  IntercomItem.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 23.10.21.
//

import Foundation

protocol IntercomItem {
    var id: UUID { get }
    var displayText: String { get }
}
