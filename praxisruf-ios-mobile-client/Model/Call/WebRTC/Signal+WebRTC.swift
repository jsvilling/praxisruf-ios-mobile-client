//
//  Signal+WebRTC.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation

extension Signal {
    
    static func offer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "OFFER", payload: payload, description: Settings().clientName, notificationOnFailedDelivery: true)
    }
    
    static func answer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "ANSWER", payload: payload, description: Settings().clientName)
    }
    
    static func ice_candidate(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "ICE_CANDIDATE", payload: payload, description: Settings().clientName)
    }
    
    static func end(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "END", payload: "", description: Settings().clientName)
    }
    
    static func unavailable(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "UNAVAILABLE", payload: "", description: Settings().clientName)
    }
    
    static func decline(recipient: String) -> Signal {
        return Signal(sender: Settings().clientId, recipient: recipient, type: "DECLINE", payload: "", description: Settings().clientName)
    }

}
