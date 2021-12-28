//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class NotificationService: ObservableObject {
    
    @Published var hasErrorResponse: Bool = false
    @Published var notificationSendResult: NotificationSendResult = NotificationSendResult(notificationId: NotificationType.data[0].id, allSuccess: true)
    
    private let settings = Settings()
    
    func sendNotification(notificationType: NotificationType) {
        let notification = SendNotification(notificationTypeId: notificationType.id, sender: settings.clientId)
        PraxisrufApi().sendNotification(sendNotification: notification) { result in
            switch result {
            case .success(let notificationSendResponse):
                DispatchQueue.main.async {
                    self.notificationSendResult = notificationSendResponse
                    self.hasErrorResponse = !notificationSendResponse.allSuccess
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func retryNotification(notificationId: UUID) {
        PraxisrufApi().retryNotification(notificationId: notificationId) { result in
            switch result {
            case .success(let notificationSendResponse):
                DispatchQueue.main.async {
                    self.notificationSendResult = notificationSendResponse
                    self.hasErrorResponse = !notificationSendResponse.allSuccess
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func receiveNotification(notification: ReceiveNotification) {
        Inbox.shared.receive(notification)
        if (notification.isTextToSpeech == "true" && settings.isSpeechSynthEnabled) {
            SpeechSynthesisService().synthesize(notification)
        }
    }
}
