//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation
import SwiftUI

class NotificationService: ObservableObject {
    
    @Published var error: Error? = nil
    
    @Published var hasDeliveryFailed: Bool = false
    @Published var notificationSendResult: NotificationSendResult = NotificationSendResult(notificationId: NotificationType.data[0].id, allSuccess: true)
    
    func sendNotification(notificationType: NotificationType) {
        let notification = SendNotification(notificationTypeId: notificationType.id, sender: Settings.standard.clientId)
        PraxisrufApi().sendNotification(sendNotification: notification) { result in
            switch result {
            case .success(let notificationSendResponse):
                DispatchQueue.main.async {
                    self.notificationSendResult = notificationSendResponse
                    self.hasDeliveryFailed = !notificationSendResponse.allSuccess
                }
            case .failure(let error):
                self.onError(error)
            }
        }
    }
    
    func retryNotification(notificationId: UUID) {
        PraxisrufApi().retryNotification(notificationId: notificationId) { result in
            switch result {
            case .success(let notificationSendResponse):
                DispatchQueue.main.async {
                    self.notificationSendResult = notificationSendResponse
                    self.hasDeliveryFailed = !notificationSendResponse.allSuccess
                }
            case .failure(let error):
                self.onError(error)
            }
        }
    }
    
    func receive(_ notification: ReceiveNotification) {
        Inbox.shared.receive(notification)
        if (notification.textToSpeech == "true" && Settings.standard.isSpeechSynthEnabled) {
            SpeechSynthesisService().synthesize(notification, onError)
        }
    }
    
    private func onError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}
