//
//  Signal+WebRTC.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation

extension Signal {
    
    static func offer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "OFFER", payload: payload, description: Settings.standard.clientName, notificationOnFailedDelivery: true)
    }
    
    static func answer(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "ANSWER", payload: payload, description: Settings.standard.clientName)
    }
    
    static func ice_candidate(recipient: String, payload: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "ICE_CANDIDATE", payload: payload, description: Settings.standard.clientName)
    }
    
    static func end(recipient: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "END", payload: "", description: Settings.standard.clientName)
    }
    
    static func unavailable(recipient: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "UNAVAILABLE", payload: "", description: Settings.standard.clientName)
    }
    
    static func decline(recipient: String) -> Signal {
        return Signal(sender: Settings.standard.clientId.uppercased(), recipient: recipient.uppercased(), type: "DECLINE", payload: "", description: Settings.standard.clientName)
    }
    
}
