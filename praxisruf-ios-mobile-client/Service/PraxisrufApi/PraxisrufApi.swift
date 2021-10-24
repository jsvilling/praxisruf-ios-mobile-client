//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation

class PraxisrufApi {
    
    enum PraxisrufApiError: Error {
        case invalidCredentials
        case custom(errorMessage: String)
    }
        
    let baseUrlValue = "https://www.praxisruf.ch/api"
    
}
