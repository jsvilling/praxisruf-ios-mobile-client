//
//  CallRequest.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 09.12.21.
//

import Foundation

/// DTO representing a PraxisrufSignal which was received from or is sent to the signaling instance
/// Signals are received and sent in PraxisrufApi+Signaling
/// Signals are processed in the classes CallClient and CallService
struct Signal : Decodable, Encodable {
    let sender: String
    let recipient: String
    let type: String
    let payload: String
    var description: String = ""
    var notificationOnFailedDelivery: Bool = false
}
