//
//  PraxisrufApi+Configuration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

extension PraxisrufApi {

    func getAvailableClients(completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        get("/clients/byUser", completion: completion)
    }
    
    func getDisplayConfiguration(clientId: String, completion: @escaping (Result<Configuration, PraxisrufApiError>) -> Void) {
        get("/configurations/types?clientId=\(clientId)", completion: completion)
    }
    
    func getRelevantNotificationTypes(clientId: String, completion: @escaping (Result<[NotificationType], PraxisrufApiError>) -> Void) {
        get("/notificationtypes/search?clientId=\(clientId)", completion: completion)
    }
    
    func getCallTypeParticipants(callTypeId: String, completion: @escaping (Result<[Client], PraxisrufApiError>) -> Void) {
        get("/calltypes/\(callTypeId)/participants", completion: completion)
    }
}
