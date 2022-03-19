//
//  Constants.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 24.10.21.
//

import Foundation

/// UserDefaultKeys wraps static string values that are used for properties stored in the UserDefaults or KeyChain
struct UserDefaultKeys {
    
    /// JWT Token for communication with cloud service
    static let authToken: String = "authToken"
    
    /// Selected configuration
    static let clientName: String = "clientName"
    static let clientId: String = "clientId"
    
    /// Token for identification with firebase cloud messaging
    static let fcmToken: String = "fcmToken"
    
    // Basic auth credentials
    static let userName: String = "userName"
    static let password: String = "password"
    
    /// Local settings
    static let isTextToSpeech: String = "isTextToSpeech"
    static let isCallsDisabled: String = "isCallsEnabled"
    
}
