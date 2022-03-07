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
    case callError
    case custom(errorMessage: String)
    case errorResponse
    case invalidCredential
    case invalidData
    
    public var localizedDescription: String? {
        switch self {
            case .connectionClosedTemp:
                return NSLocalizedString("error.connectionClosedTemp", comment: "Connection closed, but will be reopened")
            case .connectionClosedPerm:
                return NSLocalizedString("error.connectionClosedPerm", comment: "Connection closed and cannot be reopened")
            case .custom(errorMessage: let errorMessage):
                return NSLocalizedString(errorMessage, comment: "Custom Error")
            case .errorResponse:
                return NSLocalizedString("error.errorResponse", comment: "Server has returned error response")
            case .invalidCredential:
                return NSLocalizedString("error.invalidCredential", comment: "Provided credentials are invalid")
            case .invalidData:
                return NSLocalizedString("error.invalidData", comment: "Sent request contained invalid data")
            case .callError:
                return NSLocalizedString("error.callError", comment: "Error when establishing voice connection")
        }
    }
}
