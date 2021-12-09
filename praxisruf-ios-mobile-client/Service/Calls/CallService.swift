//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import SwiftKeychainWrapper

class CallService : ObservableObject {
    
    let webSocket: URLSessionWebSocketTask

    init() {
        guard let clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId) else {
            fatalError()
        }
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
                            print("Data \(signal!)")
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
        
        let signal = Signal(sender: id.uuidString, type: "OFFER")
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
