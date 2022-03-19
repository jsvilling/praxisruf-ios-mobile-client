//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation
import SwiftUI

/// This service integrates praxisruf notifications into the app.
/// It publishes properties for errors and results of sent notifications.
/// It further provides methods for sending, retrying and receiving notifications.
class NotificationService: ObservableObject {
    
    @Published var error: Error? = nil
    @Published var hasDeliveryFailed: Bool = false
    @Published var notificationSendResult: NotificationSendResult = NotificationSendResult(notificationId: NotificationType.data[0].id, allSuccess: true)
    
    var settings: Settings
    
    init(settings: Settings = Settings()) {
        self.settings = settings
    }
    
    /// Creates a SendNotification and sends it via the notification api of praxisruf.
    /// If communication with the cloudservice was successfull a notificationSendResult will be published in the corresponding property.
    /// This will contain the information if the notifications was delivered for firebase cloud messaging for all recipients.
    /// If an error occurrs during communication with the cloudservice, an error will be published.
    ///
    /// This is called by the IntercomView when a button to send a notification is tapped.
    func sendNotification(notificationType: NotificationType) {
        let notification = SendNotification(notificationTypeId: notificationType.id, sender: settings.clientId)
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
    
    /// Sends a request to the notification api to retry to send a notification.
    /// The notification will only be sent to recipients for which sending was not successfull.
    ///
    /// This is called after confirmation in a dialog in the IntercomView after a notificationSendResult was published in which
    /// the property allSuccess is false.
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
    
    /// Receives a given notification.
    /// The notification is added to the shared instance of Inbox.
    /// After this it is checked whether the notification is relevant for speech synthesis and if speech synthesis is enabled.
    /// If both are true the notification is passed to SpeechSynthesisService for processing.
    ///
    /// This is called by the AppDelegate upon receiving a notification and upon opening the app after a notification was received in the background.
    func receive(_ notification: ReceiveNotification) {
        Inbox.shared.receive(notification)
        if (notification.textToSpeech == "true" && settings.isSpeechSynthEnabled) {
            SpeechSynthesisService().synthesize(notification, onError)
        }
    }
    
    /// Publishes the given error
    private func onError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}
