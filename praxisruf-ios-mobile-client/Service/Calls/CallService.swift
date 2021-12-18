//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject, CallClientDelegate {

    private var connected: Bool = false
    private let clientId: String
    private var callClient: CallClient
    private let signalingService: SignalingService
    
    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.signalingService = SignalingService()
        self.callClient = WebRTCClient()
        self.signalingService.listen(completion: receive)
        callClient.delegate = self
    }
    
    func send(_ signal: Signal) {
        self.signalingService.send(signal)
    }
    
    func receive(_ signal: Signal) {
        print("Received Signal with type \(signal.type)")
        callClient.accept(signal: signal)
    }
    
    func updateConnectionState(connected: Bool) {
        self.connected = connected
    }
    
    func startOrEndCall(id: UUID) {
        if (self.connected) {
            callClient.endCall()
        } else {
            callClient.offer()
        }
    }
}
