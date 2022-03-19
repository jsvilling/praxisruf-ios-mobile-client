//
//  PraxisrufApi+Signaling.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation
import SwiftKeychainWrapper

/// Extension of PraxisrufApi which enables integration with the signaling instance of the cloudservice.
/// This integration is done by providing a websocket connection and the methods to interact with it.
///
/// The protocol PraxisrufApiSignalingDelegate is used to notify about changes in connection state and received messages.
///
/// This is used by the CallService to integrate signaling and establish connections.
extension PraxisrufApi {
    
    static var signalingDelegate: PraxisrufApiSignalingDelegate?
    
    /// Connection object to the singaling isntance. There must always only be one connection, as multiple connections are not supported by this app.
    private static var signalingWebSocket: URLSessionWebSocketTask? = nil;
    
    /// Compouten property which evaluates wheter the connection is present and in a usable state.
    private var disconnected: Bool {
        return PraxisrufApi.signalingWebSocket == nil || PraxisrufApi.signalingWebSocket?.closeCode.rawValue != 0
    }

    /// Establishes a websocket connection with the signalling instance.
    /// If a connection is already established, processing ends immediately.
    ///
    /// The http request made to open the websocket connection will be authenticated with the auth token from the keychain.
    ///  If no token is found, no connection will be established.
    ///
    ///  After the connection is established the SignalingDelegate will be notified, that the connectino is restored.
    ///
    ///  This is called by the CallClient to establish or repair connections.
    func connectSignalingServer(clientId: String) {
        if (!disconnected) {
            return
        }
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            print("No authToken found")
            return
        }
        let url = URL(string: "\(PraxisrufApi.webSocketBaseUrlValue)/signaling?clientId=\(clientId)")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession(configuration: .default).webSocketTask(with: request)
        task.resume()
        PraxisrufApi.signalingWebSocket = task
        PraxisrufApi.signalingDelegate?.onConnectionRestored()
    }
    
    /// Disconnects the websocket to the signaling service without trying to reconnect.
    func disconnectSignalingService() {
        PraxisrufApi.signalingWebSocket?.cancel()
        PraxisrufApi.signalingWebSocket = nil
    }

    /// Sends a ping signal over the websocket connection to the signaling service.
    /// This allows to keep the connection open even when no signals are received or sent.
    ///
    /// Before sending a ping signal it will be assumed that the connection is established or can be repaired.
    /// This is done by notifying via SignalingDelegate, that the connection has been restored.
    ///
    /// Afterwards it is checked if the connection is open.
    /// If it is closed the SignlaingDelegate will be notified with onConnectionLost.
    /// Ohterwise the ping message is sent.
    ///
    /// If sending the signal fails the SignalingDelegate is notified via onErrorReceived
    ///
    /// This is called by the CallService to keep the signaling connection open.
    func pingSignalingConnection() {
        PraxisrufApi.signalingDelegate?.onConnectionRestored()
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        PraxisrufApi.signalingWebSocket?.sendPing() { error in
            if (error != nil) {
                PraxisrufApi.signalingDelegate?.onErrorReceived(error: error!)
            } else {
                PraxisrufApi.signalingDelegate?.onConnectionRestored()
            }
        }
    }

    /// Sends a signal message over the websocket connection.
    ///
    /// Before sending a signal it will be assumed that the connection is established or can be repaired.
    /// This is done by notifying via SignalingDelegate, that the connection has been restored.
    ///
    /// Afterwards it is checked if the connection is open.
    /// If it is closed the SignlaingDelegate will be notified with onConnectionLost.
    /// After this an attempt will be amde to send the signal is sent.
    /// If sending the signal fails the SignalingDelegate is notified via onErrorReceived
    ///
    /// This is called by the CallService.
    func sendSignal(signal: Signal) {
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
        PraxisrufApi.signalingDelegate?.onConnectionRestored()
        
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        
        PraxisrufApi.signalingWebSocket?.send(message) { error in
            if (error != nil) {
                PraxisrufApi.signalingDelegate?.onErrorReceived(error: error!)
            }
        }
    }
    
    /// Notifies the websocket connection to the signaling instance, that the next signal can be received.
    ///
    /// Befor starting to listen it is checked that the connection is open and usable.
    /// If this is not the case the SignalingDelegate is notified with onConnectionLost.
    ///
    /// When a message is received it will be decoded to a Signal instance and the SignalingDelegate is notified with onSignalReceived.
    /// If decoding fails or the message has an unexpected format the SignalingDelegate is notified with onErrorReceived.
    /// The same applies if receiving a message fails alltogether.
    ///
    /// In any case, after receiving a message from the connection it will be signaled, that the next message can be received.
    ///
    /// This is called by the CallClient to receive signals.
    func listenForSignal() {
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        PraxisrufApi.signalingWebSocket?.receive() { message in
            switch(message) {
                case .success(let content):
                    switch(content) {
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                            PraxisrufApi.signalingDelegate?.onSignalReceived(signal!)
                            self.listenForSignal()
                        default:
                            PraxisrufApi.signalingDelegate?.onErrorReceived(error: PraxisrufApiError.invalidData)
                    }
                case .failure(let error):
                    // This detects whether ios shut down the connection in the background
                    if (self.disconnected || error.localizedDescription.contains("error 53")) {
                        PraxisrufApi.signalingDelegate?.onConnectionLost()
                    }
                    PraxisrufApi.signalingDelegate?.onErrorReceived(error: error)
                    self.listenForSignal()
            }
        }
    }
}
