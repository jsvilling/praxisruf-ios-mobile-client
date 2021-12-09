//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import SwiftKeychainWrapper

class CallService : ObservableObject {
    
    let clientId: String
    let webSocket: URLSessionWebSocketTask

    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.webSocket = PraxisrufApi().websocket("/name?clientId=\(clientId)")
        listen()
    }
    
    func listen() {
        webSocket.receive() { message in
            switch(message) {
                case .success(let content):
                    switch(content) {
                        case .data(let data):
                            let signal = try? JSONDecoder().decode(Signal.self, from: data)
                            if (signal!.type == "OFFER") {
                                print("Received offer")
                                self.acceptCall()
                            } else {
                                print("Received answer")
                            }
                        case .string(let s):
                            print("String \(s)")
                    }
                    print(content)
                    self.listen()
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func startCall(id: UUID) {
        print("Starting call for \(id)")
        
        let signal = Signal(sender: clientId, type: "OFFER")
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.data(content!)
        
        webSocket.send(message) { error in
            if (error != nil) {
                print("Send failed")
                print(error as Any)
            }
        }
    }
    
    func acceptCall() {
        let signal = Signal(sender: clientId, type: "ANSWER")
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.data(content!)
        
        webSocket.send(message) { error in
            if (error != nil) {
                print("Send failed")
                print(error as Any)
            }
        }
    }
}
