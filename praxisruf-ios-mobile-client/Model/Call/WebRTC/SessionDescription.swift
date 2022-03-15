//
//  SignalDescription.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation
import WebRTC

/// Data Transfer Object used to describe SDP information
/// This DTO Wraps the RTCSessionDescription class and provides methods to convert it from or to string
/// The relevant values stored as string and int properties
struct SessionDescription: Codable {
    
    let playload: String
    let type: Int
    
    /// Create DTO from RTCSessionDescription
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.playload = rtcSessionDescription.sdp
        self.type = rtcSessionDescription.type.rawValue
    }
    
    /// Create RTCSessionDescription from DTO
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: RTCSdpType.init(rawValue: type)!, sdp: self.playload)
    }
}
