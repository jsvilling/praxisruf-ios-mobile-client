//
//  WebRTCSignalType.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.02.22.
//

import Foundation

enum WebRTCSignalType: String {
    
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
