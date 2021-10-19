//
//  Client.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 19.10.21.
//

import Foundation

struct Client: Decodable, Identifiable {
    let id: UUID
    let name: String
}

extension Client {
    static var data: [Client] = [
        Client(id: UUID(), name: "Behandlungszimmer 1"),
        Client(id: UUID(), name: "Behandlungszimmer 2"),
        Client(id: UUID(), name: "Empfang"),
        Client(id: UUID(), name: "Steri")
    ]
}
