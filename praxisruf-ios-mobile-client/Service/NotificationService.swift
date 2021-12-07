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
    
    func sendNotification(notificationTypeId: UUID) {
        let defaults = UserDefaults.standard
        guard let clientId = defaults.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        let notification = SendNotification(notificationTypeId: notificationTypeId, sender: clientId)
        
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
        if (notification.isTextToSpeech == "true" && UserDefaults.standard.bool(forKey: UserDefaultKeys.isTextToSpeech)) {
            SpeechSynthesisService().synthesize(notification)
        }
    }
}
