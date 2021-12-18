//
//  SignalingService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 13.12.21.
//

import Foundation

class SignalingService {

    private let clientId: String = UserDefaults.standard.string(forKey: "clientId") ?? ""
    private var webSocket: URLSessionWebSocketTask? = nil
    
    private let api: PraxisrufApi = PraxisrufApi()
    
    func ping() {
        self.webSocket!.sendPing() { error in
            if (error != nil) {
                print("Error")
            }
            print("Pong")
        }
    }
    
    func connect() {
        PraxisrufApi().authorizedWebSocket("/signaling?clientId=\(clientId)") { result in
            switch(result) {
                case .success(let webSocket):
                    webSocket.resume()
                case .failure(let error):
                    print(error)
                    return
            }
        }
    }
    
    func listen(completion: @escaping (Signal) -> Void) {
        if (webSocket == nil) {
            connect()
        }
        webSocket?.receive() { message in
            
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
        self.webSocket!.send(message) { error in
            if (error != nil) {
                print("Error sending message")
            }
        }
        print("Sent Signal with type \(signal.type)")
    }
    
}
