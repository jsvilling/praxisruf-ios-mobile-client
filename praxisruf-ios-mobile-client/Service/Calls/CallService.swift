//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject, CallClientDelegate {

    @Published var callStarted: Bool = false
    @Published var callTypeId: String = ""
    
    private var connected: Bool = false
    private let clientId: String
    private var callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init() {
        self.clientId = UserDefaults.standard.string(forKey: "clientId") ?? "clientId"
        self.praxisrufApi = PraxisrufApi()
        self.callClient = CallClient()
        callClient.delegate = self
    }
    
    func listen() {
        self.praxisrufApi.connectSignalingServer(clientId: clientId)
        self.praxisrufApi.listenForSignal(completion: receive)
    }
    
    func ping(_ input: Any? = nil) {
        self.praxisrufApi.pingSignalingConnection()
    }
    
    func send(_ signal: Signal) {
        self.praxisrufApi.sendSignal(signal: signal)
    }
    
    func receive(_ signal: Signal) {
        print("Received Signal with type \(signal.type)")
        if (signal.type == "OFFER") {
            self.callStarted = true
        } else if (signal.type == "END") {
            self.callStarted = false
        }
        callClient.accept(signal: signal)
    }
    
    func updateConnectionState(connected: Bool) {
        self.connected = connected
    }
    
    func toggleMute() {
        self.callClient.toggleMute()
    }
    
    func initCall(id: UUID) {
        self.callStarted = true
        self.callTypeId = id.uuidString
    }
    
    func startCall() {
        PraxisrufApi().getCallType(callTypeId: self.callTypeId) { result in
            switch result {
                case .success(let callType):
                    print("Starting call for \(callType.id)")
                    self.callClient.offer(targetId: callType.participants[0])
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func endCall() {
        // Update model
        self.callTypeId = ""
        self.callStarted = false
        self.connected = false
        
        // Dispose of old client
        callClient.endCall()
        callClient.delegate = nil
        
        // Init new client
        callClient = CallClient()
        callClient.delegate = self
    }
}
