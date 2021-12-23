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
    func updateState(clientId: String, state: String)
}

class CallClient : NSObject {
    
    var delegate: CallClientDelegate?
    var direction: String = ""
    
    private let clientId: String
    private let clientName: String
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    private var peerConnections: [String: RTCPeerConnection] = [:]
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let factory: RTCPeerConnectionFactory
    
    private let config: RTCConfiguration
    private let constraints: RTCMediaConstraints
    
    private var muted = false;
    
    override required init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId) ?? ""
        self.clientName = UserDefaults.standard.string(forKey: UserDefaultKeys.clientName) ?? "UNKNOWN"
        self.config = RTCConfiguration()

        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        RTCInitializeSSL()
        factory = RTCPeerConnectionFactory()
    }
    
    private func initNextPeerConnection(targetId: String) {
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            fatalError("Could not create new RTCPeerConnection")
        }
        self.peerConnections[targetId.uppercased()] = peerConnection
        self.createMediaSenders(targetId: targetId)
        self.configureAudioSession(targetId: targetId)
        peerConnection.delegate = self
        
    }
    
    private func configureAudioSession(targetId: String) {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders(targetId: String) {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnections[targetId.uppercased()]!.add(audioTrack, streamIds: [streamId])
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.factory.audioSource(with: audioConstrains)
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func offer(targetId: String) {
        
        if (targetId.uppercased() == self.clientId.uppercased()) {
            return
        }
        
        initNextPeerConnection(targetId: targetId)
        self.direction = "SENDING"
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        
        self.peerConnections[targetId.uppercased()]!.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            self.peerConnections[targetId.uppercased()]!.setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let offer = Signal(sender: self.clientId, recipient: targetId, type: "OFFER", payload: payloadString!, description: self.clientName)
                self.delegate!.send(offer)
            }
        }
    }
        
    func endCall(signalOther: Bool = true) {
        self.peerConnections.forEach() { cv in
            if (signalOther) {
                let endSignal = Signal(sender: clientId, recipient: cv.key, type: "END", payload: "")
                self.delegate?.send(endSignal)
            } else {
                cv.value.close()
            }
            cv.value.delegate = nil
        }
        self.peerConnections.removeAll()
    }
    
    func accept(signal: Signal) {
        if (signal.type == "OFFER") {
            initNextPeerConnection(targetId: signal.sender)
            setRemoteSdp(signal: signal)
            answer(targetId: signal.sender)
        } else if (signal.type == "ANSWER") {
            setRemoteSdp(signal: signal)
        } else if (signal.type == "ICE_CANDIDATE") {
            addIceCandidate(signal: signal)
        } else if (signal.type == "END") {
            endCall(signalOther: false)
        } else if (signal.type == "UNAVAILABLE") {
            delegate?.updateState(clientId: signal.sender.uppercased(), state: "UNAVAILABLE")
        } else {
            print("Unknown Signal Type \(signal.type)")
        }
    }
    
    private func setRemoteSdp(signal: Signal) {
        let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: signal.payload.data(using: .utf8)!)
        self.peerConnections[signal.sender.uppercased()]!.setRemoteDescription(sdpWrapper!.rtcSessionDescription, completionHandler: self.printError)
    }
    
    private func answer(targetId: String) {
        self.direction = "RECEIVING"
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnections[targetId.uppercased()]!.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            self.peerConnections[targetId.uppercased()]!.setLocalDescription(sdp, completionHandler: self.printError)
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let answer = Signal(sender: self.clientId, recipient: targetId, type: "ANSWER", payload: payloadString!, description: self.clientName)
            self.delegate!.send(answer)
        }
    }
    
    private func addIceCandidate(signal: Signal) {
        let iceWrapper = try? JSONDecoder().decode(IceCandidate.self, from: signal.payload.data(using: .utf8)!)
        self.peerConnections[signal.sender.uppercased()]!.add(iceWrapper!.rtcIceCandidate, completionHandler: self.printError)
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
        peerConnections.values.forEach() { c in
                c.transceivers
                    .compactMap { return $0.sender.track as? T }
                    .forEach { $0.isEnabled = isEnabled }
        }
    }
}

extension CallClient : RTCPeerConnectionDelegate {
    
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
        var state = ""
        switch(newState) {
            case .new:
                state = "NEW"
            case .checking:
                state = "CHECKING"
            case .connected:
                state = "CONNECTED"
            case .completed:
                state = "COMPLETED"
            case .failed:
                state = "FAILED"
            case .disconnected:
                state = "DISCONNECTED"
            case .closed:
                state = "CLOSED"
            case .count:
                state = "COUNT"
            default:
                state = "UNKNOWN"
            }
        
        let id = peerConnections.first { $0.value == peerConnection }?.key
        if (id != nil) {
            delegate?.updateState(clientId: id!, state: state)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        if (self.direction == "") {
            return
        }
        let iceCandidate = IceCandidate(from: candidate)
        let payloadData = try? JSONEncoder().encode(iceCandidate)
        let payloadString = String(data: payloadData!, encoding: .utf8)
        
        guard let targetId = self.peerConnections.first(where: { $1 == peerConnection })?.key else {
            return
        }
        
        let signal = Signal(sender: self.clientId, recipient: targetId, type: "ICE_CANDIDATE", payload: payloadString!)
        self.delegate!.send(signal)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}


