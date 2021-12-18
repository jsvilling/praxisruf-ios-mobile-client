//
//  SignalDescription.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation
import WebRTC

struct SessionDescription: Codable {
    let sdp: String
    let rawType: Int
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        self.rawType = rtcSessionDescription.type.rawValue
    }
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: RTCSdpType.init(rawValue: rawType)!, sdp: self.sdp)
    }
}
