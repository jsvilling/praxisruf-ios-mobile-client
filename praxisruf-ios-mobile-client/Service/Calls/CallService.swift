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
        self.webSocket = PraxisrufApi().websocket("/name")
        acceptNextCall()
    }
    
    func acceptNextCall() {
        webSocket.receive() { request in
            AudioPlayer.playSystemSound(soundID: 1006)
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
