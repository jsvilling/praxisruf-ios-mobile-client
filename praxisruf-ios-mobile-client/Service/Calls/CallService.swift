//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject {

    @Published var active: Bool = false
    @Published var callTypeId: String = ""
    @Published var state: String = "NONE"
    @Published var callPartnerName: String = ""
    
    private let clientId: String
    
    private var callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init() {
        clientId = UserDefaults.standard.string(forKey: "clientId") ?? "clientId"
        praxisrufApi = PraxisrufApi()
        callClient = CallClient()
        callClient.delegate = self
        PraxisrufApi.signalingDelegate = self
    }
    
    func listen() {
        praxisrufApi.connectSignalingServer(clientId: clientId)
        praxisrufApi.listenForSignal()
    }
    
    func ping(_ input: Any? = nil) {
        praxisrufApi.pingSignalingConnection() 
    }
    
    func toggleMute() {
        self.callClient.toggleMute()
    }
    
    func initCall(id: UUID) {
        self.active = true
        self.callTypeId = id.uuidString
    }
    
    func startCall() {
        PraxisrufApi().getCallType(callTypeId: self.callTypeId) { result in
            switch result {
                case .success(let callType):
                    print("Starting call for \(callType.id)")
                    self.callClient.offer(targetIds: callType.participants)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func endCall() {
        self.callTypeId = ""
        self.state = "NONE"
        self.active = false
        callClient.endCall()
    }

}

extension CallService : CallClientDelegate {
    
    func send(_ signal: Signal) {
        praxisrufApi.sendSignal(signal: signal)
    }
    
}

extension CallService : PraxisrufApiSignalingDelegate {
    
    func onConnectionLost() {
        listen()
    }
    
    func onSignalReceived(_ signal: Signal) {
        self.state = "RECEIVED \(signal.type)"
        
        if (signal.description != "") {
            self.callPartnerName = signal.description
        }
        
        if (signal.type == "OFFER") {
            active = true
            Inbox.shared.receive(signal)
        } else if (signal.type == "END") {
            active = false
        }
        callClient.accept(signal: signal)
    }
    
    func onErrorReceived(error: Error) {
        print(error.localizedDescription)
    }
    
}
