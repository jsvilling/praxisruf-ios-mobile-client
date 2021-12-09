//
//  CallService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation

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
                    print("Success")
                    switch(content) {
                        case .data(let data):
                            print("Data")
                            print(data)
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                                
                            if (signal!.type == "OFFER") {
                                print("Received offer")
                                self.acceptCall()
                            } else {
                                print("Call Accepted")
                            }
                    }
                case .failure(let error):
                    print("Error")
                    print(error)
            }
            
            
            //print(message)
            self.listen()
        }
    }
    
    func startCall(id: UUID) {
        print("Starting call for \(id)")
        
        let signal = Signal(sender: clientId, type: "OFFER")
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
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
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        
        webSocket.send(message) { error in
            if (error != nil) {
                print("Send failed")
                print(error as Any)
            }
        }
    }
}
