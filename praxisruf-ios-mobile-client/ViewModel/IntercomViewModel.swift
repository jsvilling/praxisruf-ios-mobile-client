//
//  IntercomViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class IntercomViewModel: ObservableObject {
    
    @Published var hasErrorResponse: Bool
    @Published var notificationSendResult: NotificationSendResult?
    @Published var notificationTypes: [NotificationType]
    
    init(notificationTypes: [NotificationType] = []) {
        self.hasErrorResponse = false
        self.notificationTypes = notificationTypes
        self.notificationSendResult = nil
    }
    
    func getNotificationTypes() {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No token found")
            return
        }

        guard let clientId = defaults.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        PraxisrufApi().getRelevantNotificationTypes(clientId: clientId, token: token) { result in
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
        
        print("Sending notification \(notificationTypeId)")
        
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No token found")
            return
        }

        guard let clientId = defaults.string(forKey: UserDefaultKeys.clientId) else {
            print("No clientId found")
            return
        }
        
        let notification = SendNotification(notificationTypeId: notificationTypeId, sender: clientId)
        
        PraxisrufApi().sendNotification(authToken: token, sendNotification: notification) { result in
            switch result {
            case .success(let notificationSendResponse):
                print("Success in viewmodel called")
                DispatchQueue.main.async {
                    self.hasErrorResponse = !notificationSendResponse.allSuccess
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
}
