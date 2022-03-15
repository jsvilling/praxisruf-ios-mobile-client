//
//  Signal+WebRTC.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation

/// Extension for Signal Struct
/// This extension provides factory methods for creating Praxisruf Signals
/// A factory method is provided for each type specified in the enum PraxisrufSignalType
extension Signal {
    
    static func offer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.OFFER.rawValue, payload: payload, description: Settings().clientName, notificationOnFailedDelivery: true)
    }
    
    static func answer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.ANSWER.rawValue, payload: payload, description: Settings().clientName)
    }
    
    static func ice_candidate(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.ICE_CANDIDATE.rawValue, payload: payload, description: Settings().clientName)
    }
    
    static func end(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.END.rawValue, payload: "", description: Settings().clientName)
    }
    
    static func unavailable(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.UNAVAILABLE.rawValue, payload: "", description: Settings().clientName)
    }
    
    static func decline(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: PraxisrufSignalType.DECLINE.rawValue, payload: "", description: Settings().clientName)
    }

}
