//
//  Registration.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 08.12.21.
//

import Foundation

struct Registration : Decodable {
    let clientName: String
    let fcmToken: String
}
