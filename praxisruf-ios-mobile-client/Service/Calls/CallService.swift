//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : NSObject, ObservableObject {
    
    let clientId: String
    let webSocket: URLSessionWebSocketTask
    
    // WebRTC
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var peerConnection: RTCPeerConnection

    override required init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.webSocket = PraxisrufApi().websocket("/name?clientId=\(clientId)")
        
        let config = RTCConfiguration()
        //config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
       
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        
        guard let peerConnection = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory).peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            fatalError("Could not create new RTCPeerConnection")
        }
        peerConnection.delegate = self
        self.peerConnection = peerConnection
        
        listen()
    }
    
    func listen() {
        webSocket.receive() { message in
            
            switch(message) {
                case .success(let content):
                    print("Success")
                    switch(content) {
                        case .data(let data):
                            print("Data")
                            print(data)
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                                
                            if (signal!.type == "OFFER") {
                                print("Received offer")
                                self.acceptCall(singal: signal!)
                            } else {
                                print("Call Accepted")
                            }
                    }
                case .failure(let error):
                    print("Error")
                    print(error)
            }

            self.listen()
        }
    }
    
    func startCall(id: UUID) {
        print("Starting call for \(id)")

        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        
        self.peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            self.peerConnection.setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let signal = Signal(sender: self.clientId, type: "OFFER", payload: payloadString!)
                let content = try? JSONEncoder().encode(signal)
                let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
                
                print(String(data: content!, encoding: .utf8)!)
                
                self.webSocket.send(message) { error in
                    if (error != nil) {
                        print("Send failed")
                        print(error as Any)
                    }
                }
                
                print("Offer Sent")
            }
        }
    }
    
    func acceptCall(singal: Signal) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        
        let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: singal.payload.data(using: .utf8)!)
        
        self.peerConnection.setRemoteDescription(sdpWrapper!.rtcSessionDescription) { error in
            print("Error setting remote SDP")
        }
        
        self.peerConnection.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                print("Answer failed")
            })
        
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let signal = Signal(sender: self.clientId, type: "ANSWER", payload: payloadString!)
            let content = try? JSONEncoder().encode(signal)
            let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
            
            print(String(data: content!, encoding: .utf8)!)
            
            self.webSocket.send(message) { error in
                if (error != nil) {
                    print("Send failed")
                    print(error as Any)
                }
            }
            
            print("Answer Sent")
        }
        
    }
}


extension CallService : RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection new connection state: \(newState)")
        // TODO: Update connection state
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        //TODO: Set discovered local candidate
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        // TODO: Set Remote data channel
    }
}



/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        case .rollback: return .rollback
        }
    }
}

/// This struct is a swift wrapper over `RTCSessionDescription` for easy encode and decode
struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        
        switch rtcSessionDescription.type {
        case .offer:    self.type = .offer
        case .prAnswer: self.type = .prAnswer
        case .answer:   self.type = .answer
        case .rollback: self.type = .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}
