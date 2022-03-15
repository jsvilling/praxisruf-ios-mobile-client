//
//  Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation

/// This DTO Represents the registration of a client with Firebase Cloud Messaging
/// It is sent to the Configuration domain of the cloudservice after registration with Firebase.
/// It is used in the Cloudservice to send notifications according to the configuration
struct Registration : Decodable {
    let clientName: String
    let fcmToken: String
}
