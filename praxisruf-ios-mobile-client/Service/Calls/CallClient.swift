//
//  Client.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation
import WebRTC

protocol CallClient {
    var signalingDelegate: SignalingDelegate { get set }
    
    func offer()
    
    func accept(signal: Signal)
}

protocol SignalingDelegate {
    func send(_ signal: Signal)
}

class WebRTCClient : NSObject, CallClient {
    var signalingDelegate: SignalingDelegate
    
    private let clientId: String
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let factory: RTCPeerConnectionFactory
    
    required init(signalingDelegate: SignalingDelegate) {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings:  ["stun:stun.l.google.com:19302",
                                                        "stun:stun1.l.google.com:19302",
                                                        "stun:stun2.l.google.com:19302",
                                                        "stun:stun3.l.google.com:19302",
                                                        "stun:stun4.l.google.com:19302"])]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
       
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        self.factory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        self.signalingDelegate = signalingDelegate
        
        super.init()
        
        self.createMediaSenders()
        self.configureAudioSession()
        peerConnection.delegate = self
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.factory.audioSource(with: audioConstrains)
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func offer() {
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        
        self.peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            self.peerConnection.setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let offer = Signal(sender: self.clientId, type: "OFFER", payload: payloadString!)
                self.signalingDelegate.send(offer)
            }
        }
    }
    
    func accept(signal: Signal) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        
        let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: signal.payload.data(using: .utf8)!)
        
        self.peerConnection.setRemoteDescription(sdpWrapper!.rtcSessionDescription) { error in
            if (error != nil) {
                print("Error setting remote SDP")
                print(error)
            }
        }
        
        self.peerConnection.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                if (error != nil) {
                    print("Answer failed")
                }
            })
        
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let answer = Signal(sender: self.clientId, type: "ANSWER", payload: payloadString!)
            self.signalingDelegate.send(answer)
        }
    }
    
    private func acceptOffer(signal: Signal) {
        print("Accepting Offer")
    }
    
    private func acceptAnswer(signal: Signal) {
        print("Accepting Answer")
    }
    
    private func acceptIceCandidate(signal: Signal) {
        print("Accepting IceCandidate")
    }
    

    
}

extension WebRTCClient : RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection new signaling state: \(self.peerConnection.signalingState)")
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
        let iceCandidate = IceCandidate(from: candidate)
        let payloadData = try? JSONEncoder().encode(iceCandidate)
        let payloadString = String(data: payloadData!, encoding: .utf8)
        let signal = Signal(sender: self.clientId, type: "ICE_CANDIDATE", payload: payloadString!)
        self.signalingDelegate.send(signal)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}


