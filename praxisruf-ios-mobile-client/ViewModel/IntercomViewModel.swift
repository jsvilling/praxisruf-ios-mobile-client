//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class IntercomViewModel: ObservableObject {
    
    @Published var hasErrorResponse: Bool
    @Published var notificationSendResult: NotificationSendResult
    @Published var notificationTypes: [NotificationType]
    
    init(notificationTypes: [NotificationType] = []) {
        self.hasErrorResponse = false
        self.notificationTypes = notificationTypes
        self.notificationSendResult = NotificationSendResult(notificationId: NotificationType.data[0].id, allSuccess: true)
    }
    
    func getNotificationTypes() {
        let defaults = UserDefaults.standard
        guard let clientId = defaults.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        PraxisrufApi().getRelevantNotificationTypes(clientId: clientId) { result in
            switch result {
                case .success(let notificationTypes):
                    DispatchQueue.main.async {
                        self.notificationTypes = notificationTypes
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
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
}
