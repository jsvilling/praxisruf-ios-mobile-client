//
//  PraxisrufApi+Signaling.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation
import SwiftKeychainWrapper

protocol PraxisrufApiSignalingDelegate {
    func onConnectionLost()
    func onSignalReceived(_ signal: Signal)
    func onErrorReceived(error: Error)
}

extension PraxisrufApi {
    
    static var signalingDelegate: PraxisrufApiSignalingDelegate?
    
    private static var singalingWebSocket: URLSessionWebSocketTask? = nil;
    
    private var disconnected: Bool {
        return PraxisrufApi.singalingWebSocket == nil || PraxisrufApi.singalingWebSocket?.closeCode.rawValue != 0
    }

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
        PraxisrufApi.singalingWebSocket = task
    }
    
    func disconnectSignalingService() {
        PraxisrufApi.singalingWebSocket = nil
    }

    func pingSignalingConnection() {
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        PraxisrufApi.singalingWebSocket?.sendPing() { error in
            if (error != nil) {
                PraxisrufApi.signalingDelegate?.onErrorReceived(error: error!)
            }
        }
    }

    func sendSignal(signal: Signal) {
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        
        PraxisrufApi.singalingWebSocket?.send(message) { error in
            if (error != nil) {
                PraxisrufApi.signalingDelegate?.onErrorReceived(error: error!)
            }
        }
    }
    
    func listenForSignal() {
        if (disconnected) {
            PraxisrufApi.signalingDelegate?.onConnectionLost()
        }
        PraxisrufApi.singalingWebSocket?.receive() { message in
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
                    PraxisrufApi.signalingDelegate?.onErrorReceived(error: error)
            }
        }
    }
}
