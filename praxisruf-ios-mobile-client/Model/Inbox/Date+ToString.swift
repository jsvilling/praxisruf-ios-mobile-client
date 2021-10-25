//
//  Date+ToString.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

extension Date {

    func toString() -> String {
        return formatter().string(from: self)
    }
    
    private func formatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
}
