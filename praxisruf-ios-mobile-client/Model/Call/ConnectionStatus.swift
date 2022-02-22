//
//  ConnectionStatus.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 22.02.22.
//

import Foundation


enum ConnectionStatus {
 
    // The connection is established
    case CONNECTED
    
    // The connection has ended for any reason
    case DISCONNECTED
    
    // The connection is being established or repaired
    case PROCESSING
    
    // Any state that is not covered by the states above
    // This is added for stability but should never be used. 
    case UNKNOWN
    
}
