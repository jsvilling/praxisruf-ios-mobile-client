//
//  CallClientDelegate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 15.03.22.
//

import Foundation

/// This protocol defines methods which can be used by CallClient to publish changes that are relevant outside of the local connection objects. 
protocol CallClientDelegate {
    func send(_ signal: Signal)
    func updateState(clientId: String, state: ConnectionStatus)
    func onIncommingCallPending(signal: Signal)
    func onIncomingCallDeclined(signal: Signal)
    func onCallEnded()
    func onCallError()
}
