//
//  ReceiveNotification.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 07.12.21.
//

import Foundation

struct ReceiveNotification {
    let notificationType: String
    let version: String
    let title: String
    let body: String
    let sender: String
    let senderId: String
    let textToSpeech: String
    
    init(_ notificationType: String, _ version: String, _ title: String, _ body: String, _ sender: String, _ senderId: String, _ textToSpeech: String) {
        self.notificationType = notificationType
        self.version = version
        self.title = title
        self.body = body
        self.sender = sender
        self.senderId = senderId
        self.textToSpeech = textToSpeech
    }
}
