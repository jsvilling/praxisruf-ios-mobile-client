//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject {
    
    private var connected: Bool = false
    private let clientId: String
    private let callClient: CallClient
    private let signalingService: SignalingService
    
    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.signalingService = SignalingService()
        self.callClient = WebRTCClient(signalingDelegate: self.signalingService)
        self.signalingService.listen(completion: receive)
    }
    
    func startOrEndCall(id: UUID) {
        if (self.connected) {
            callClient.endCall()
        } else {
            callClient.offer()
        }
    }
    
    func receive(_ signal: Signal) {
        print("Received Signal with type \(signal.type)")
        callClient.accept(signal: signal)
    }
    
    func updateConnectionState(connected: Bool) {
        self.connected = connected
    }
}
