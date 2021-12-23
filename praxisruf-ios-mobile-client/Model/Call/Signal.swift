//
//  CallRequest.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 09.12.21.
//

import Foundation

struct Signal : Decodable, Encodable {
    let sender: String
    let recipient: String
    let type: String
    let payload: String
    var description: String = ""
}
