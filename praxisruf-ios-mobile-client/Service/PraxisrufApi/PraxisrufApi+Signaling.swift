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
    
    private static var delegate: PraxisrufApiSignalingDelegate?
    private static var websocket: URLSessionWebSocketTask? = nil;
    
    private var disconnected: Bool {
        return PraxisrufApi.websocket == nil || PraxisrufApi.websocket?.closeCode.rawValue != 0
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
        PraxisrufApi.websocket = task
    }

    func pingSignalingConnection() {
        if (disconnected) {
            PraxisrufApi.delegate?.onConnectionLost()
        }
        PraxisrufApi.websocket?.sendPing() { error in
            if (error != nil) {
                PraxisrufApi.delegate?.onErrorReceived(error: error!)
            }
        }
    }
    
    func pingSignalingConnection(completion: @escaping (Result<Nothing, PraxisrufApiError>) -> Void) {
        if (disconnected) {
            completion(.failure(PraxisrufApiError.connectionClosedTemp))
        }
        PraxisrufApi.websocket?.sendPing() { error in
            if (error != nil) {
                completion(.failure(PraxisrufApiError.errorResponse))
            } else {
                completion(.success(Nothing()))
            }
        }
    }

    func sendSignal(signal: Signal, completion: @escaping (Result<Nothing, PraxisrufApiError>) -> Void) {
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
        if (disconnected) {
            completion(.failure(PraxisrufApiError.connectionClosedTemp))
        }
        
        PraxisrufApi.websocket?.send(message) { error in
            if (error != nil) {
                completion(.failure(PraxisrufApiError.errorResponse))
            } else {
                completion(.success(Nothing()))
            }
        }
    }
    
    func listenForSignal(completion: @escaping (Result<Signal, PraxisrufApiError>) -> Void) {
        if (disconnected) {
            completion(.failure(PraxisrufApiError.connectionClosedTemp))
        }
        PraxisrufApi.websocket?.receive() { message in
            switch(message) {
                case .success(let content):
                    switch(content) {
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                            completion(.success(signal!))
                            self.listenForSignal(completion: completion)
                        default:
                            completion(.failure(PraxisrufApiError.invalidData))
                            return
                    }
                case .failure(let error):
                    completion(.failure(PraxisrufApiError.custom(errorMessage: error.localizedDescription)))
            }
        }
    }
}
