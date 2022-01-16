//
//  EmptyState.swift
//  praxisruf-ios-mobile-client
//
//  Adapted from https://peterfriese.dev/swiftui-empty-state/
//
//  Created by J. Villing on 15.01.22.
//

import Foundation
import SwiftUI

struct ConditionalViewModifier<V>: ViewModifier where V: View {
    var condition: Bool
    let conditionalView: () -> V
    
    func body(content: Content) -> some View {
        if (condition) {
          conditionalView()
        } else {
            content
        }
    }
}

extension View {
    func onConditionReplaceWith<V>(_ condition: Bool, emptyView: @escaping () -> V) -> some View where V: View {
        modifier(ConditionalViewModifier(condition: condition, conditionalView: emptyView))
    }
}
