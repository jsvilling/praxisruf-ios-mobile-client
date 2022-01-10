//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC
import SwiftUI

class CallService : ObservableObject {

    @Published var error: Error? = nil
    @Published var active: Bool = false
    @Published var callTypeId: String = ""
    @Published var states: [String:(String, String)] = [:]
    @Published var callPartnerName: String = ""
    var settings: Settings
    
    private let callClient: CallClient
    private let praxisrufApi: PraxisrufApi
    
    init(settings: Settings = Settings()) {
        self.settings = settings
        praxisrufApi = PraxisrufApi()
        callClient = CallClient()
        callClient.delegate = self
        PraxisrufApi.signalingDelegate = self
    }
    
    func listen() {
        praxisrufApi.connectSignalingServer(clientId: settings.clientId)
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
                        .filter({ p in p.id.uuidString != self.settings.clientId.uppercased() })
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
            Inbox.shared.receiveCall(signal)
        }
    }
    
    func onIncomingCallDeclined(signal: Signal) {
        let content = UNMutableNotificationContent()
        content.title = signal.description
        content.body = "Automatically declined call"
        content.categoryIdentifier = "local"
        content.sound = UNNotificationSound.default

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
        let notificationCenter = UNUserNotificationCenter.current()
    
        notificationCenter.add(request) { (error) in }
        
        DispatchQueue.main.async {
            Inbox.shared.receiveDeclinedCall(signal)
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
        if (signal.recipient.uppercased() != self.settings.clientId.uppercased()) {
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
        if (settings.isIncomingCallsDisabled) {
            self.callClient.decline(signal: signal)
        } else {
            self.callClient.accept(signal: signal)
        }
    }
    
    func onErrorReceived(error: Error) {
        //print(error.localizedDescription)
    }
    
}
