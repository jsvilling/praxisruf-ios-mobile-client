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
    func onIncomingCallStarted(signal: Signal)
    func onCallEnded()
}

class CallClient : NSObject {
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let factory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    private let config: RTCConfiguration = RTCConfiguration()
    private let constraints: RTCMediaConstraints = RTCMediaConstraints(mandatoryConstraints: [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue, kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse], optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
    
    private let clientId: String
    private let clientName: String
    private var peerConnections: [String: RTCPeerConnection] = [:]
    private var muted = false;
    
    var delegate: CallClientDelegate?
    
    required init(clientId: String, clientName: String) {
        self.clientId = clientId
        self.clientName = clientName
        self.config.sdpSemantics = .unifiedPlan
        self.config.continualGatheringPolicy = .gatherContinually
        RTCInitializeSSL()
    }
    
    private func initNextPeerConnection(targetId: String) -> RTCPeerConnection {
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            delegate?.updateState(clientId: targetId, state: "FAILED")
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
                let offer = Signal(sender: self.clientId, recipient: targetId, type: "OFFER", payload: payloadString!, description: self.clientName)
                self.delegate?.send(offer)
            }
        }
    }
        
    func endCall(signalOther: Bool = true) {
        self.peerConnections.forEach() { cv in
            if (signalOther) {
                let endSignal = Signal(sender: clientId, recipient: cv.key, type: "END", payload: "")
                self.delegate?.send(endSignal)
                cv.value.close()
                cv.value.delegate = nil
            }
        }
        self.peerConnections.removeAll()
        self.delegate?.onCallEnded()
    }
    
    func accept(signal: Signal) {
        if (signal.type == "OFFER") {
            let peerConnection = initNextPeerConnection(targetId: signal.sender)
            setRemoteSdp(signal: signal, peerConnection: peerConnection)
            answer(targetId: signal.sender, peerConnection: peerConnection)
            self.delegate?.onIncomingCallStarted(signal: signal)
        } else if (signal.type == "ANSWER") {
            setRemoteSdp(signal: signal)
        } else if (signal.type == "ICE_CANDIDATE") {
            addIceCandidate(signal: signal)
        } else if (signal.type == "END") {
            endCall(signalOther: false)
        } else if (signal.type == "UNAVAILABLE") {
            delegate?.updateState(clientId: signal.sender.uppercased(), state: "UNAVAILABLE")
        } else if (signal.type == "DECLINE") {
            self.delegate?.updateState(clientId: signal.sender, state: "DECLINED")
        } else {
            print("Unknown Signal Type \(signal.type)")
        }
    }
    
    func decline(signal: Signal) {
        if (signal.type == "OFFER") {
            let signal = Signal(sender: self.clientId, recipient: signal.sender, type: "DECLINE", payload: "", description: self.clientName)
            self.delegate?.send(signal)
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
            let answer = Signal(sender: self.clientId, recipient: targetId, type: "ANSWER", payload: payloadString!, description: self.clientName)
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
    
    func toggleMute() {
        self.muted = !self.muted
        peerConnections.values.forEach() { c in
                c.transceivers
                    .compactMap { return $0.sender.track as? RTCAudioTrack }
                    .forEach { $0.isEnabled = !self.muted }
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
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let iceCandidate = IceCandidate(from: candidate)
        let payloadData = try? JSONEncoder().encode(iceCandidate)
        let payloadString = String(data: payloadData!, encoding: .utf8)
        
        guard let targetId = self.peerConnections.first(where: { $1 == peerConnection })?.key else {
            return
        }
        
        let signal = Signal(sender: self.clientId, recipient: targetId, type: "ICE_CANDIDATE", payload: payloadString!)
        self.delegate?.send(signal)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }
}


