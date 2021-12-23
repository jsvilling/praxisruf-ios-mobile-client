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
    private let callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId) ?? ""
        let clientName = UserDefaults.standard.string(forKey: UserDefaultKeys.clientName) ?? "UNKNOWN"
        
        praxisrufApi = PraxisrufApi()
        callClient = CallClient(clientId: clientId, clientName: clientName)
        callClient.delegate = self
        PraxisrufApi.signalingDelegate = self
    }
    
    func listen() {
        praxisrufApi.connectSignalingServer(clientId: clientId)
        praxisrufApi.listenForSignal()
    }
    
    func disconnect() {
        praxisrufApi.disconnectSignalingService()
    }
    
    func ping(_ input: Any? = nil) {
        praxisrufApi.pingSignalingConnection() 
    }
    
    func toggleMute() {
        self.callClient.toggleMute()
    }
    
    func initCall(calltype: DisplayCallType) {
        DispatchQueue.main.async {
            self.active = true
            self.callTypeId = calltype.id.uuidString
            self.callPartnerName = calltype.displayText
        }
    }
    
    func startCall() {
        PraxisrufApi().getCallTypeParticipants(callTypeId: self.callTypeId) { result in
            switch result {
                case .success(let participants):
                    participants
                        .filter({ p in p.id.uuidString != self.clientId.uppercased() })
                        .forEach() { p in
                            self.initCallPartnerState(p: p)
                            self.callClient.offer(targetId: p.id.uuidString)
                        }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    private func initCallPartnerState(p: Client) {
        DispatchQueue.main.async {
            self.states[p.id.uuidString] = (p.name, "REQUESTED")
        }
    }
    
    func endCall() {
        callClient.endCall()
    }

}

extension CallService : CallClientDelegate {
    
    func onIncomingCallStarted(signal: Signal) {
        DispatchQueue.main.async {
            self.active = true
            self.callPartnerName = signal.description
            Inbox.shared.receive(signal)
        }
    }
    
    func onCallEnded() {
        DispatchQueue.main.async {
            self.callTypeId = ""
            self.callPartnerName = ""
            self.states.removeAll()
            self.active = false
        }
    }
    
    func updateState(clientId: String, state: String) {
        DispatchQueue.main.async {
            self.states[clientId]?.1 = state
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
        praxisrufApi.disconnectSignalingService()
        listen()
    }
    
    func onSignalReceived(_ signal: Signal) {
        self.callClient.accept(signal: signal)
    }
    
    func onErrorReceived(error: Error) {
        //print(error.localizedDescription)
    }
    
}
