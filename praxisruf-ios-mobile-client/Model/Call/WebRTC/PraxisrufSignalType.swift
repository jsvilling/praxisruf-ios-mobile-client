//
//  WebRTCSignalType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.02.22.
//

import Foundation

/// This enum describes the types of Signals known in Praxisruf
/// This contains the Signals OFFER, ANSWER and ICE_CANDIDATE which are mandatory for WebRTC.
/// It also contains the Signals END, UNAVAILABLE and DECLINE which are specific to Praxisruf.
/// Signals are processed according to their type in the CallClient service. 
enum PraxisrufSignalType: String {
    
    case OFFER = "OFFER"
    case ANSWER = "ANSWER"
    case ICE_CANDIDATE = "ICE_CANDIDATE"
    case END = "END"
    case UNAVAILABLE = "UNAVAILABLE"
    case DECLINE = "DECLINE"
    
    func equals(value: String) -> Bool {
        return self.rawValue == value
    }
    
}
