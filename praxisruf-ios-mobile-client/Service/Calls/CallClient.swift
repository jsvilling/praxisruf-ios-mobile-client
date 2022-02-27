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
    func updateState(clientId: String, state: ConnectionStatus)
    func onIncommingCallPending(signal: Signal)
    func onIncomingCallDeclined(signal: Signal)
    func onCallEnded()
}

class CallClient : NSObject {
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let factory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    private let config: RTCConfiguration = RTCConfiguration()
    private let constraints: RTCMediaConstraints = RTCMediaConstraints(mandatoryConstraints: [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue, kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse], optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
    
    private var peerConnections: [String: RTCPeerConnection] = [:]
    private var audioEnabled = true;
    
    var delegate: CallClientDelegate?
    
    override required init() {
        self.config.sdpSemantics = .unifiedPlan
        self.config.continualGatheringPolicy = .gatherContinually
        self.config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302",
                                                           "stun:stun1.l.google.com:19302",
                                                           "stun:stun2.l.google.com:19302",
                                                           "stun:stun3.l.google.com:19302",
                                                           "stun:stun4.l.google.com:19302"])]
        RTCInitializeSSL()
    }
    
    private func initNextPeerConnection(targetId: String) -> RTCPeerConnection {
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            delegate?.updateState(clientId: targetId, state: .DISCONNECTED)
            // TODO: Handle this properly
            fatalError("Could not create new RTCPeerConnection")
        }
        self.peerConnections[targetId.uppercased()] = peerConnection
        self.createMediaSenders(targetId: targetId)
        self.configureAudioSession(targetId: targetId)
        peerConnection.delegate = self
        return peerConnection
        
    }
    
    private func configureAudioSession(targetId: String) {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            try self.rtcAudioSession.overrideOutputAudioPort(.none)
            try self.rtcAudioSession.setInputGain(0)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders(targetId: String) {
        let audioSource = self.factory.audioSource(with: constraints)
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: "audio0")
        self.peerConnections[targetId.uppercased()]!.add(audioTrack, streamIds: [targetId])
    }
    
    func offer(targetId: String) {
        let peerConnection = initNextPeerConnection(targetId: targetId)
        peerConnection.offer(for: constraints) { (sdp, error) in
            guard let sdp = sdp else {
                print("No sdp")
                return
            }
            peerConnection.setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let offer = Signal.offer(recipient: targetId, payload: payloadString!)
                self.delegate?.send(offer)
            }
        }
    }
        
    func endCall() {
        self.peerConnections.forEach() { cv in
            let endSignal = Signal.end(recipient: cv.key)
            self.delegate?.send(endSignal)
            cv.value.close()
            cv.value.delegate = nil
        }
        self.peerConnections.removeAll()
        self.delegate?.onCallEnded()
    }
    
    func endConnection(signal: Signal) {
        self.peerConnections[signal.sender]?.close()
        self.peerConnections.removeValue(forKey: signal.sender)
        if (self.peerConnections.isEmpty) {
            self.delegate?.onCallEnded()
        }
        delegate?.updateState(clientId: signal.sender, state: .DISCONNECTED)
    }
    
    func receive(signal: Signal) {
        let type = WebRTCSignalType.init(rawValue: signal.type)
        switch(type) {
            case .some(.OFFER):
                delegate?.onIncommingCallPending(signal: signal)
            case .some(.ANSWER):
                setRemoteSdp(signal: signal)
            case .some(.ICE_CANDIDATE):
                addIceCandidate(signal: signal)
            case .some(.END):
                endConnection(signal: signal)
            case .some(.UNAVAILABLE):
                delegate?.updateState(clientId: signal.sender.uppercased(), state: .DISCONNECTED)
            case .some(.DECLINE):
                self.peerConnections[signal.sender]?.close()
                self.delegate?.updateState(clientId: signal.sender, state: .DISCONNECTED)
            case .none:
                print("Unknown Signal Type \(signal.type)")
        }
    }
    
    func accept(signal: Signal) {
        let peerConnection = initNextPeerConnection(targetId: signal.sender)
        setRemoteSdp(signal: signal, peerConnection: peerConnection)
        answer(targetId: signal.sender, peerConnection: peerConnection)
    }
    
    func decline(signal: Signal) {
        if (WebRTCSignalType.OFFER.equals(value: signal.type)) {
            let declineSignal = Signal.decline(recipient: signal.sender)
            self.delegate?.send(declineSignal)
            self.delegate?.onIncomingCallDeclined(signal: signal)
        } else {
            self.receive(signal: signal)
        }
    }
    
    private func setRemoteSdp(signal: Signal) {
        guard let peerConnection = self.peerConnections[signal.sender.uppercased()] else {
            return
        }
        setRemoteSdp(signal: signal, peerConnection: peerConnection)
    }
    
    private func setRemoteSdp(signal: Signal, peerConnection: RTCPeerConnection) {
        let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: signal.payload.data(using: .utf8)!)
        peerConnection.setRemoteDescription(sdpWrapper!.rtcSessionDescription, completionHandler: self.printError)
    }
    
    private func answer(targetId: String, peerConnection: RTCPeerConnection) {
        peerConnection.answer(for: constraints) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            peerConnection.setLocalDescription(sdp, completionHandler: self.printError)
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let answer = Signal.answer(recipient: targetId, payload: payloadString!)
            self.delegate?.send(answer)
        }
    }
    
    private func addIceCandidate(signal: Signal) {
        let iceWrapper = try? JSONDecoder().decode(IceCandidate.self, from: signal.payload.data(using: .utf8)!)
        self.peerConnections[signal.sender.uppercased()]?.add(iceWrapper!.rtcIceCandidate, completionHandler: self.printError)
    }
    
    private func printError(error: Error?) {
        if (error != nil) {
            print("Error in CallClient")
            print(error!)
        }
    }
    
    func toggleMute(state: Bool) {
        toggleAudioTrack(state: state) { r in
            r.sender.track as? RTCAudioTrack
        }
    }
    
    func toggleSpeaker(state: Bool) {
        toggleAudioTrack(state: state) { r in
            r.receiver.track as? RTCAudioTrack
        }
    }
    
    private func toggleAudioTrack(state: Bool, supplier: (RTCRtpTransceiver) -> RTCAudioTrack? ) {
        peerConnections.values.forEach() { c in
                c.transceivers
                    .compactMap { supplier($0) }
                    .forEach { $0?.isEnabled = !state }
        }
    }
}

extension CallClient : RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        var connectionState: ConnectionStatus
        switch(newState) {
            case .new, .checking, .count:
                connectionState = .PROCESSING
            case .connected:
                connectionState = .CONNECTED
            case .completed, .failed, .disconnected, .closed:
                connectionState = .DISCONNECTED
            default:
                connectionState = .UNKNOWN
            }
        
        let id = peerConnections.first { $0.value == peerConnection }?.key
        if (id != nil) {
            delegate?.updateState(clientId: id!, state: connectionState)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let iceCandidate = IceCandidate(from: candidate)
        let payloadData = try? JSONEncoder().encode(iceCandidate)
        let payloadString = String(data: payloadData!, encoding: .utf8)
        
        guard let targetId = self.peerConnections.first(where: { $1 == peerConnection })?.key else {
            return
        }
        
        let signal = Signal.ice_candidate(recipient: targetId, payload: payloadString!)
        self.delegate?.send(signal)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}


