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
    let callClient: CallClient
    let signalingService: SignalingService
    
    init() {
        self.clientId = UserDefaults.standard§.string(forKey: UserDefaultKeys.clientId)!
        self.signalingService = SignalingService()
        self.callClient = WebRTCClient(signalingDelegate: self.signalingService)
        self.signalingService.listen(completion: receive)
    }
    
    func startCall(id: UUID) {
        print("Starting call for \(id)")
        callClient.offer()
    }
    
    func receive(_ signal: Signal) {
        print("Received Signal with type \(signal.type)")
        callClient.accept(signal: signal)
    }
}
