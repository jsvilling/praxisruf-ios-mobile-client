//
//  Client.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation
import WebRTC

protocol CallClientDelegate {
    func send(_ signal: Signal)
    func updateConnectionState(connected: Bool)
}

class CallClient : NSObject {
    
    var delegate: CallClientDelegate?
    var targetId: String = ""
    
    private let clientId: String
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    private var peerConnections: [RTCPeerConnection] = []
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let factory: RTCPeerConnectionFactory
    
    private let config: RTCConfiguration
    private let constraints: RTCMediaConstraints
    
    private var muted = false;
    
    override required init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId) ?? ""
        self.config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings:  ["stun:stun.l.google.com:19302",
                                                        "stun:stun1.l.google.com:19302",
                                                        "stun:stun2.l.google.com:19302",
                                                        "stun:stun3.l.google.com:19302",
                                                        "stun:stun4.l.google.com:19302"])]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        RTCInitializeSSL()
        factory = RTCPeerConnectionFactory()
        super.init()
        initNextPeerConnection()
    }
    
    private func initNextPeerConnection() {
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            fatalError("Could not create new RTCPeerConnection")
        }
        self.peerConnections.append(peerConnection)
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
        self.peerConnections[0].add(audioTrack, streamIds: [streamId])
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.factory.audioSource(with: audioConstrains)
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func offer(targetId: String) {
        self.targetId = targetId
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        
        self.peerConnections[0].offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            self.peerConnections[0].setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let offer = Signal(sender: self.clientId, recipient: targetId, type: "OFFER", payload: payloadString!)
                self.delegate!.send(offer)
            }
        }
    }
        
    func endCall(signalOther: Bool = true) {
        if (signalOther) {
            let endSignal = Signal(sender: clientId, recipient: targetId, type: "END", payload: "")
            self.delegate?.send(endSignal)
        }
        self.targetId = ""
        self.peerConnections[0].close()
        self.peerConnections[0].delegate = nil
        self.peerConnections.remove(at: 0)
        initNextPeerConnection()
    }
    
    func accept(signal: Signal) {
        if (signal.type == "OFFER") {
            setRemoteSdp(signal: signal)
            answer(targetId: signal.sender)
        } else if (signal.type == "ANSWER") {
            setRemoteSdp(signal: signal)
        } else if (signal.type == "ICE_CANDIDATE") {
            addIceCandidate(signal: signal)
        } else if (signal.type == "END") {
            endCall(signalOther: false)
        } else {
            print("Unknown Signal Type \(signal.type)")
        }
    }
    
    private func setRemoteSdp(signal: Signal) {
        let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: signal.payload.data(using: .utf8)!)
        self.peerConnections[0].setRemoteDescription(sdpWrapper!.rtcSessionDescription, completionHandler: self.printError)
    }
    
    private func answer(targetId: String) {
        self.targetId = targetId
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnections[0].answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnections[0].setLocalDescription(sdp, completionHandler: self.printError)
        
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let answer = Signal(sender: self.clientId, recipient: targetId, type: "ANSWER", payload: payloadString!)
            self.delegate!.send(answer)
        }
    }
    
    private func addIceCandidate(signal: Signal) {
        let iceWrapper = try? JSONDecoder().decode(IceCandidate.self, from: signal.payload.data(using: .utf8)!)
        self.peerConnections[0].add(iceWrapper!.rtcIceCandidate, completionHandler: self.printError)
    }
    
    private func printError(error: Error?) {
        if (error != nil) {
            print("Error in CallClient")
            print(error!)
        }
    }
    
    func toggleMute() {
        self.muted = !self.muted
        setTrackEnabled(RTCAudioTrack.self, isEnabled: !self.muted)
    }
    
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnections[0].transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

extension CallClient : RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection new signaling state: \(self.peerConnections[0].signalingState)")
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
        if (newState == RTCIceConnectionState.connected) {
            self.delegate!.updateConnectionState(connected: true)
        } else if (newState == RTCIceConnectionState.disconnected || newState == RTCIceConnectionState.closed || newState == RTCIceConnectionState.failed) {
            self.targetId = ""
            self.delegate!.updateConnectionState(connected: false)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        if (self.targetId == "") {
            return
        }
        let iceCandidate = IceCandidate(from: candidate)
        let payloadData = try? JSONEncoder().encode(iceCandidate)
        let payloadString = String(data: payloadData!, encoding: .utf8)
        let signal = Signal(sender: self.clientId, recipient: self.targetId, type: "ICE_CANDIDATE", payload: payloadString!)
        self.delegate!.send(signal)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}


