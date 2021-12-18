//
//  SignalingService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation

class SignalingService {

    private let clientId: String
    private let webSocket: URLSessionWebSocketTask
    
    init() {
        self.clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)!
        self.webSocket = PraxisrufApi().websocket("/signaling?clientId=\(clientId)")
    }
    
    func listen(completion: @escaping (Signal) -> Void) {
        webSocket.receive() { message in
            
            switch(message) {
                case .success(let content):
                    switch(content) {
                        case .string(let string):
                            let signal = try? JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
                            print("Received Signal with type \(signal!.type)")
                            completion(signal!)
                        default:
                            fatalError("Invalid Signal received")
                    }
                case .failure(let error):
                    print("Error")
                    print(error)
            }

            self.listen(completion: completion)
        }
    }
    
    func send(_ signal: Signal) {
        let content = try? JSONEncoder().encode(signal)
        let message = URLSessionWebSocketTask.Message.string(String(data: content!, encoding: .utf8)!)
        self.webSocket.send(message) { error in
            if (error != nil) {
                print("Error sending message")
            }
        }
        print("Sent Signal with type \(signal.type)")
    }
    
}
