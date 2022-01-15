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

struct OnEmptyViewModifier<V>: ViewModifier where V: View {
    var isEmpty: Bool
    let emptyView: () -> V
    
    func body(content: Content) -> some View {
        if (isEmpty) {
          emptyView()
        } else {
            content
        }
    }
}

extension View {
    func onEmpty<V>(_ isEmpty: Bool, emptyView: @escaping () -> V) -> some View where V: View {
        modifier(OnEmptyViewModifier(isEmpty: isEmpty, emptyView: emptyView))
    }
}
