//
//  PraxisrufApi+Signaling.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation
import SwiftKeychainWrapper

extension PraxisrufApi {
    
    private static var websocket: URLSessionWebSocketTask? = nil;
    
    func connectSignalingServer(clientId: String) {
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
        PraxisrufApi.websocket?.sendPing() { error in
            if (error != nil) {
                print("Error")
            }
        }
    }
    
    func sendSignal(signal: Signal) {
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        PraxisrufApi.websocket?.send(message) { error in
            if (error != nil) {
                print("Error sending message")
            }
        }
    }
    
    func listenForSignal(completion: @escaping (Signal) -> Void) {
        guard let socket = PraxisrufApi.websocket else {
            print("Signaling Server is not conneted")
            return
        }
        socket.receive() { message in
            switch(message) {
                case .success(let content):
                    switch(content) {
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                            completion(signal!)
                        default:
                            fatalError("Invalid Signal received")
                    }
                case .failure(let error):
                    print("Error")
                    print(error)
            }
            self.listenForSignal(completion: completion)
        }
    }
}
