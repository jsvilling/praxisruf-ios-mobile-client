//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject {

    @Published var callStarted: Bool = false
    @Published var callTypeId: String = ""
    
    private let clientId: String
    
    private var callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init() {
        clientId = UserDefaults.standard.string(forKey: "clientId") ?? "clientId"
        praxisrufApi = PraxisrufApi()
        callClient = CallClient()
        callClient.delegate = self
    }
    
    func listen() {
        praxisrufApi.connectSignalingServer(clientId: clientId)
        praxisrufApi.listenForSignal() { result in
            switch(result) {
                case .failure(let error):
                    self.onSignalingError(error)
                case .success(let signal):
                    self.receive(signal)
            }
        }
    }
    
    func ping(_ input: Any? = nil) {
        praxisrufApi.pingSignalingConnection() { result in
            switch(result) {
                case .failure(let error):
                    self.onSignalingError(error)
                case .success(_):
                    print()
            }
        }
    }
        
    func receive(_ signal: Signal) {
        if (signal.type == "OFFER") {
            callStarted = true
            Inbox.shared.receive(signal)
        } else if (signal.type == "END") {
            callStarted = false
        }
        callClient.accept(signal: signal)
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
                    self.callClient.offer(targetIds: callType.participants)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func endCall() {
        self.callTypeId = ""
        self.callStarted = false
        callClient.endCall()
    }
    
    
    private func onSignalingError(_ error: PraxisrufApiError) {
        switch(error) {
            case PraxisrufApiError.connectionClosedTemp:
                print("Attempting reconnect")
                listen()
            default:
                print(error.localizedDescription)
        }
    }
}

extension CallService : CallClientDelegate {
    
    func send(_ signal: Signal) {
        praxisrufApi.sendSignal(signal: signal) { result in
            switch(result) {
                case .failure(let error):
                    self.onSignalingError(error)
                case .success(_):
                    print()
            }
        }
    }
    
    func updateConnectionState(connected: Bool) {
        self.callStarted = connected
    }
    
}

extension CallService : PraxisrufApiSignalingDelegate {
    
    func onConnectionLost() {
        listen()
    }
    
    func onSignalReceived(_ signal: Signal) {
        if (signal.type == "OFFER") {
            callStarted = true
            Inbox.shared.receive(signal)
        } else if (signal.type == "END") {
            callStarted = false
        }
        callClient.accept(signal: signal)
    }
    
    func onErrorReceived(error: Error) {
        print(error.localizedDescription)
    }
    
    
}
