//
//  SignalingDelegate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 15.03.22.
//

import Foundation

/// This protocol defines methods which can be used by PraxisrufApi+Signaling to publish changes that are relevant outside of the local connection objects. 
protocol PraxisrufApiSignalingDelegate {
    func onConnectionLost()
    func onSignalReceived(_ signal: Signal)
    func onErrorReceived(error: Error)
    func onConnectionRestored()
}
