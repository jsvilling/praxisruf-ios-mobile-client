//
//  Date+ToString.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import Foundation

/// Extension of the Date class to provide a simple String representation in the format DD.MM.YY, hh.mm
extension Date {

    /// Creates a string representing the given date in the format DD.MM.YY, hh.mm
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
