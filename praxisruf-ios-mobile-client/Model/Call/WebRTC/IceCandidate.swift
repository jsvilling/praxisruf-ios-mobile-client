//
//  IceCandidate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation
import WebRTC

/// Data Transfer Object used to describe ICE_CANDIDATE information
/// This DTO Wraps the RTCIceCandidate class and provides methods to convert it from or to string
/// The relevant values stored as string and int properties
struct IceCandidate: Codable {
    
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    
    /// Create DTO from RTCIceCandidate
    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
        self.sdp = iceCandidate.sdp
    }
    
    /// Create RTCIceCandidate from DTO
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
