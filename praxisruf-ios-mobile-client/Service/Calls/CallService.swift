//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import WebRTC

class CallService : ObservableObject {
    

    func startCall(id: UUID) {
        print("Starting call for \(id)")
                
        let task = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://www.praxisruf.ch/name")!)
        task.resume()

        let textMessage = URLSessionWebSocketTask.Message.string("Joshua")
        task.send(textMessage) { error in
            if (error != nil) {
                print("Send failed")
                print(error)
            }
        }
        
        task.receive() { result in
            print(result)
        }
    }
    
    
}
