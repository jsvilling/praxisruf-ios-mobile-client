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
    @Published var states: [String:(String, String)] = [:]
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
    
    func initCall(calltype: DisplayCallType) {
        self.active = true
        self.callTypeId = calltype.id.uuidString
        self.callPartnerName = calltype.displayText
    }
    
    func startCall() {
        PraxisrufApi().getCallTypeParticipants(callTypeId: self.callTypeId) { result in
            switch result {
                case .success(let participants):
                    DispatchQueue.main.async {
                        participants
                            .filter({ p in p.id.uuidString != self.clientId.uppercased() })
                            .forEach() { p in
                                self.states[p.id.uuidString] = (p.name, "REQUESTED")
                                self.callClient.offer(targetId: p.id.uuidString)
                            }

                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func endCall() {
        self.callTypeId = ""
        self.states.removeAll()
        self.active = false
        callClient.endCall()
    }

}

extension CallService : CallClientDelegate {
    
    func updateState(clientId: String, state: String) {
        DispatchQueue.main.async {
            self.states[clientId]?.1 = state
            if (state == "DISCONNECTED") {
                self.active = false
            }
        }
    }
    
    func send(_ signal: Signal) {
        if (signal.recipient.uppercased() != self.clientId.uppercased()) {
            praxisrufApi.sendSignal(signal: signal)
        }
    }
    
}

extension CallService : PraxisrufApiSignalingDelegate {
    
    func onConnectionLost() {
        listen()
    }
    
    func onSignalReceived(_ signal: Signal) {
        self.callClient.accept(signal: signal)
        DispatchQueue.main.async {
            if (signal.type == "OFFER") {
                self.active = true
                self.callPartnerName = signal.description
                Inbox.shared.receive(signal)
            } else if (signal.type == "END") {
                self.active = false
            }
        }
    }
    
    func onErrorReceived(error: Error) {
        print(error.localizedDescription)
    }
    
}
