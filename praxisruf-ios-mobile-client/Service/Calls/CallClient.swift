//
//  CallClient.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//
import Foundation
import WebRTC

/// This service manages peer to peer connections using WebRTC.
/// This allows the integration of real time communication for calls between clients.
class CallClient : NSObject {
    
    /// Handles access to AVAudioSession and manages microphone/speaker access
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    
    /// Factory class used when creating a new connection to another client
    private let factory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    
    /// Basic configuration object for RTC.
    /// Additional values are set in CallClient.init()
    private let config: RTCConfiguration = RTCConfiguration()
    
    /// Constraints that will be used by RTCPeerConnectionFactory when creating a connection object
    private let constraints: RTCMediaConstraints = RTCMediaConstraints(
        mandatoryConstraints: [
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,     // Use audio capability
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse],   // Do not use video capability
       optionalConstraints: [
            "DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue]                       // Force SRTP with DTLS
    )
    
    /// Dictionary mapping created peer connections by the client id of the associated participant
    private var peerConnections: [String: RTCPeerConnection] = [:]
    
    /// CallClientDelegate instance.
    /// This is used to publish changes made inside this service and integrate them into the rest of the application.
    var delegate: CallClientDelegate?
    
    override required init() {
        RTCInitializeSSL()                                        /// Initialize and clean up the SSL library
        self.config.sdpSemantics = .unifiedPlan                   /// SDP Format
        self.config.continualGatheringPolicy = .gatherContinually /// Continue gathering ICE Candidates if netowork conditions change
        self.config.iceServers = []                               /// Empty list of ICE Servers - This means connections will be only possible if a direct connection can be established.
                                                                  /// If you wish to enable connections if no direct connection is possible, you cann add your STUN or TURN server like:
                                                                  /// self.config.iceServers = [RTCIceServer(urlStrings: ["url-to-your-ice-server"] )
                                                                  /// self.config.iceServers = [RTCIceServer(urlStrings: ["url-to-your-ice-server"], "username", "credential" )
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)    /// Play audio (use speaker) and record audio (use microphone)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)                /// Allow playing and recording audio at the same time and continuousely
            try self.rtcAudioSession.overrideOutputAudioPort(.none)                                 /// Do not override output channel
            try self.rtcAudioSession.setInputGain(0)                                                /// Set input gain to 0 to reduce distortion and feedback
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    /// Initializes a call by creating a RTCPeerConnection and creating an OFFER signal.
    /// The initialized RTCPeerConnection is added to the connection dictionary with the given id.
    /// The RTCPeerConnection is sued to generade an OFFER signal with the required SDP information.
    /// This signal is sent via the CallClientDelegate.
    /// If creating the OFFER fails, processing is aborted and an error is published via CallClientDelegate.
    ///
    /// This is called by CallService when initializing an outgoing call.
    func offer(targetId: String) {
        let peerConnection = initNextPeerConnection(targetId: targetId)
        peerConnection?.offer(for: constraints) { (sdp, error) in
            guard let sdp = sdp else {
                self.delegate?.onCallError()
                return
            }
            peerConnection?.setLocalDescription(sdp) { error in
                let sdpWrapper = SessionDescription(from: sdp)
                let payloadData = try? JSONEncoder().encode(sdpWrapper)
                let payloadString = String(data: payloadData!, encoding: .utf8)
                let offer = Signal.offer(recipient: targetId, payload: payloadString!)
                self.delegate?.send(offer)
            }
        }
    }
    
    /// Initializes an RTCPeerConnection for the given clientId.
    ///
    /// The connection is created with the RTCPeerConnectionFactory and then inserted in self.peerConnections with the given id.
    /// The connection is initialized with the RTCPeerConfiguration self.config and self.constraints.
    /// If creating the connection failes, CallClientDelegate is used to publish a state change to DISCONNECTED and notify that an error occurred.
    ///
    /// If no connection was initialized nil is returned.
    private func initNextPeerConnection(targetId: String) -> RTCPeerConnection? {
        guard let peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        else {
            delegate?.updateState(clientId: targetId, state: .DISCONNECTED)
            delegate?.onCallError()
            return nil
        }
        
        let audioSource = self.factory.audioSource(with: constraints)
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: targetId)
        peerConnection.add(audioTrack, streamIds: [targetId])
        peerConnection.delegate = self
        
        self.peerConnections[targetId.uppercased()] = peerConnection
        return peerConnection
    }
    
    /// Initializes RTCPeerConnection for sender of given signal.
    ///
    /// The connection is created with the RTCPeerConnectionFactory and then inserted in self.peerConnections with the given id.
    /// The connection is initialized with the RTCPeerConfiguration self.config and self.constraints.
    ///
    /// The SDP information is extracted from the signal and set as remote SDP information on the created RTCPeerConnection.
    /// After this the local SDP information of the created connection are used to create and send an ANSWER signal.
    ///
    /// If creating the connection or ANSWER signal failes, CallClientDelegate is used to notify that an error occurred.
    ///
    /// This is called by the CallService when initializing an incoming call.
    func accept(signal: Signal) {
        guard let peerConnection = initNextPeerConnection(targetId: signal.sender) else {
            self.delegate?.onCallError()
            return
        }
        setRemoteSdp(signal: signal, peerConnection: peerConnection)
        
        peerConnection.answer(for: constraints) { (sdp, error) in
            guard let sdp = sdp else {
                self.delegate?.onCallError()
                return
            }
            peerConnection.setLocalDescription(sdp, completionHandler: self.processError)
            let sdpWrapper = SessionDescription(from: sdp)
            let payloadData = try? JSONEncoder().encode(sdpWrapper)
            let payloadString = String(data: payloadData!, encoding: .utf8)
            let answer = Signal.answer(recipient: signal.sender, payload: payloadString!)
            self.delegate?.send(answer)
        }
    }
    
    /// Declines an incoming call.
    /// This is only relevant for OFFER signals.
    /// Any signals that are not of Type offer will be processed normally.
    /// This allows starting calls even when receiving them is disabled.
    ///
    /// As incoming calls do not yet have an registered RTCPeerConnections nothing in the connections has to be changed.
    /// A DECLINE signal is generated and send via the CallClientDelegate.
    /// Afterwards CallClientDelegate is used to notify, that the call has been declined.
    ///
    /// This is called by CallService if a signal was received and receiving calls is disabled in the local settings.
    func decline(signal: Signal) {
        if (PraxisrufSignalType.OFFER.equals(value: signal.type)) {
            let declineSignal = Signal.decline(recipient: signal.sender)
            self.delegate?.send(declineSignal)
            self.delegate?.onIncomingCallDeclined(signal: signal)
        } else {
            self.receive(signal: signal)
        }
    }
        
    /// This closes and unregisteres all known RTCPeerConnections.
    /// After a connection is closed an END signal is created and sent via CallClientDelegate.
    /// After all connections have been closed CallClientDelegate is used to notify, that the call was ended.
    ///
    /// This is called by CallService in response to the EndCall Button on the ActiveCallView being tapped.
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
    
    /// Processes incoming signals.
    /// * OFFER: Notify with CallClientDelegate that incomming call from sender of this signal is pending
    /// * ANSWER: Update SDP information on RTCPeerConnection of the sender of this signal
    /// * ICE_CANDIDATE: Add the received candidate to list of candidates
    /// * END: Close the RTCPeerConnection to the sender of this signal.
    /// * UNAVAILABLE: Remove RTCPeerConnection of the sender and update the state of the related connection via CallClientDelegate
    /// * DECLINE: Remove RTCPeerConnection of the sender and update the state of the related connection via CallClientDelegate
    /// * default: Notify about error via CallClientDelegate
    func receive(signal: Signal) {
        let type = PraxisrufSignalType.init(rawValue: signal.type)
        switch(type) {
            case .some(.OFFER):
                receiveOffer(signal: signal)
            case .some(.ANSWER):
                setRemoteSdp(signal: signal)
            case .some(.ICE_CANDIDATE):
                addIceCandidate(signal: signal)
            case .some(.END):
                endConnection(signal: signal)
            case .some(.UNAVAILABLE):
                self.peerConnections.removeValue(forKey: signal.sender)
                delegate?.updateState(clientId: signal.sender.uppercased(), state: .DISCONNECTED)
            case .some(.DECLINE):
                self.peerConnections[signal.sender]?.close()
                self.peerConnections.removeValue(forKey: signal.sender)
                self.delegate?.updateState(clientId: signal.sender, state: .DISCONNECTED)
            case .none:
                self.delegate?.onCallError()
                print("Unknown Signal Type \(signal.type)")
        }
    }
    
    /// Receives an offer and notifies CallClientDelegate with onIncommingCallPending.
    private func receiveOffer(signal: Signal) {
            delegate?.onIncommingCallPending(signal: signal)
    }
    
    /// This is is closes the connection of the sender of the given signal.
    /// If all known connections are closed after this CallClientDelegate is used to notify that the call has ended.
    /// Otherwise the state change of the closed connection is published va CallClientDelegate.
    private func endConnection(signal: Signal) {
        self.peerConnections[signal.sender]?.close()
        self.peerConnections.removeValue(forKey: signal.sender)
        if (self.peerConnections.isEmpty) {
            self.delegate?.onCallEnded()
        }
        delegate?.updateState(clientId: signal.sender, state: .DISCONNECTED)
    }
    
    /// Sets the remote SDP information on the RTCPeerConnection of the sender of this signal.
    /// If the connection is now knonw an error is published via CallClientDelegate.
    private func setRemoteSdp(signal: Signal) {
        guard let peerConnection = self.peerConnections[signal.sender.uppercased()] else {
            self.delegate?.onCallError()
            return
        }
        setRemoteSdp(signal: signal, peerConnection: peerConnection)
    }
    
    /// Extracts SDP information from the given signal on the given peerConnection.
    /// If extracting the SDP information fails an error is published via CallClientDelegate.
    private func setRemoteSdp(signal: Signal, peerConnection: RTCPeerConnection) {
        guard let sdpWrapper = try? JSONDecoder().decode(SessionDescription.self, from: signal.payload.data(using: .utf8)!) else {
            delegate?.onCallError()
            return
        }
        peerConnection.setRemoteDescription(sdpWrapper.rtcSessionDescription, completionHandler: self.processError)
    }
    
    /// Extracts ICE Candidate information from the given signal and adds it to the ICE Candidate list of the connection of the sender of the signal.
    /// If the Connection is not found or extracting the ICE Candidate information fails an error is published via CallClientDelegate.
    private func addIceCandidate(signal: Signal) {
        guard let iceWrapper = try? JSONDecoder().decode(IceCandidate.self, from: signal.payload.data(using: .utf8)!) else {
            self.delegate?.onCallError()
            return
        }
        self.peerConnections[signal.sender.uppercased()]?.add(iceWrapper.rtcIceCandidate, completionHandler: self.processError)
    }
    
    /// This is a callback function that can be used for calls that return optional errors.
    /// If the error is nill, nothing will be done.
    /// If the error is present it is logged and an error is published via CallClientDelegate.
    private func processError(error: Error?) {
        if (error != nil) {
            print("Error in CallClient")
            print(error!)
            self.delegate?.onCallError()
        }
    }
    
    /// Mutes or unmutes the microphone based on the given state value.
    /// This is called by the CallService when the mute microphone button is tapped on the ActiveCallView.
    func toggleMute(state: Bool) {
        toggleAudioTrack(state: state) { r in
            r.sender.track as? RTCAudioTrack
        }
    }
    
    /// Mutes or unmutes the speaker based on the given state value.
    /// This is called by the CallService when the mute speaker button is tapped on the ActiveCallView.
    func toggleSpeaker(state: Bool) {
        toggleAudioTrack(state: state) { r in
            r.receiver.track as? RTCAudioTrack
        }
    }
    
    /// Retrieves the audioTrack for each known Connections.
    /// Each audioTrack has transceivers for sending and receiving data.
    /// This method enables/disables a transceiver by setting isEnabled to the given state value.
    /// Which transceiver is enabled/disabled is determined by the given supplier.
    private func toggleAudioTrack(state: Bool, supplier: (RTCRtpTransceiver) -> RTCAudioTrack? ) {
        peerConnections.values.forEach() { c in
                c.transceivers
                    .compactMap { supplier($0) }
                    .forEach { $0?.isEnabled = !state }
        }
    }
}

extension CallClient : RTCPeerConnectionDelegate {
    
    /// Is called when the RTCSignalingState of a connection changes.
    /// During this phase signaling messages are exchanged via the signaling service.
    /// The state displayed in the UI will always be PROCESSING in this case.
    /// This menas, that there is nothing to do in this case but the method has to be implemented to satisfy RTCPeerConnectionDelegate
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    
    /// This is called when an RTCMediaStream is added.
    /// There is nothing to do in this case because connections in Praxisruf will never change after initialization.
    /// However this method has to be implemented to satisfy RTCPeerConnectionDelegate.
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    
    /// This is called when an RTCMediaStream is removed.
    /// There is nothing to do in this case because connections in Praxisruf will never change after initialization.
    /// However this method has to be implemented to satisfy RTCPeerConnectionDelegate.
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    
    /// This is called when an RTCIceConnectionState changes.
    ///
    /// Creating and closing connections is handled via the signaling instance.
    /// The state displayed in the UI will always be PROCESSING in this case.
    /// This state is updated again if the connection is established successfully and if the connection closes or faild.
    ///
    /// The update of these state changes is made via the CallClientDelegate.
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
    
    /// This is called when the RTCIceGatheringState changes.
    /// There is nothing to do in this case.
    /// However this method has to be implemented to satisfy RTCPeerConnectionDelegate.
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    
    /// This is called when a new RTCIceCandidate is discovered.
    /// In this case a ICE_CANDIDATE signal is created with the Ice Candidate data and sent view CallClientDelegate to the
    /// client with the associated id.
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
    
    /// This is called when a new RTCIceCandidate is removed.
    /// There is nothing to do in this case.
    /// However this method has to be implemented to satisfy RTCPeerConnectionDelegate.
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    
    /// This is called when a new RTCDataChannel is opened.
    /// There is nothing to do in this case.
    /// However this method has to be implemented to satisfy RTCPeerConnectionDelegate.
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}


