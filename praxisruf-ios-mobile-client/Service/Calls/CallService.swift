//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation
import SwiftKeychainWrapper

class CallService : ObservableObject {
    

    func startCall(id: UUID) {
        print("Starting call for \(id)")
                
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            
            return
        }
        
        var request = URLRequest(url: URL(string: "wss://www.praxisruf.ch/name")!)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
       
        let task = URLSession(configuration: .default).webSocketTask(with: request)
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
