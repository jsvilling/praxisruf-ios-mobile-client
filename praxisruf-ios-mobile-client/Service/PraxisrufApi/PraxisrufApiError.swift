//
//  PraxisrufApiError.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.12.21.
//

import Foundation

public enum PraxisrufApiError: Error {
    case connectionClosedTemp
    case connectionClosedPerm
    case custom(errorMessage: String)
    case errorResponse
    case invalidCredential
    case invalidData
    case noData
}
