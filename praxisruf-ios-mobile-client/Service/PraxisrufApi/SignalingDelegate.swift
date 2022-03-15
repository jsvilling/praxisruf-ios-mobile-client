//
//  SignalingDelegate.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 15.03.22.
//

import Foundation

protocol PraxisrufApiSignalingDelegate {
    func onConnectionLost()
    func onSignalReceived(_ signal: Signal)
    func onErrorReceived(error: Error)
    func onConnectionRestored()
}
