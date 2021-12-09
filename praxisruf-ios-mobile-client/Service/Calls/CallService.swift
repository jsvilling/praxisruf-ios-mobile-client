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
        acceptNextCall()
    }
    
    func acceptNextCall() {
        webSocket.receive() { request in
            print(request)
            self.acceptNextCall()
        }
    }
    
    func startCall(id: UUID) {
        print("Starting call for \(id)")
                
        let textMessage = URLSessionWebSocketTask.Message.string("\(id)")
        webSocket.send(textMessage) { error in
            if (error != nil) {
                print("Send failed")
                print(error as Any)
            }
        }
    }
}
