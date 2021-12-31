//
//  Utils.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 31.12.21.
//

import Foundation
import SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}
