//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject {
    
    let clientId: String
    let webSocket: URLSessionWebSocketTask
    
    // WebRTC
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    private var peerConnection: RTCPeerConnection?

    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.webSocket = PraxisrufApi().websocket("/name?clientId=\(clientId)")
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
                                self.acceptCall()
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
        
        let config = RTCConfiguration()
        //config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        
        let c = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        guard let peerConnection: RTCPeerConnection? = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory).peerConnection(with: config, constraints: c, delegate: nil)
        else {
            print("Error initializing rtc connection")
            return
        }
        self.peerConnection = peerConnection
        
        self.peerConnection?.offer(for: c) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            self.peerConnection?.setLocalDescription(sdp) { error in
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
    
    func acceptCall() {
        let signal = Signal(sender: clientId, type: "ANSWER", payload: "")
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
        webSocket.send(message) { error in
            if (error != nil) {
                print("Send failed")
                print(error as Any)
            }
        }
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
