//
//  ErrorHandling.swift
//  praxisruf-ios-mobile-client
//
//  Implementation is partially based on: https://www.swiftbysundell.com/articles/propagating-user-facing-errors-in-swift/
//
//  Created J. Villing user on 31.12.21.
//

import Foundation
import SwiftUI

struct Presentation: Identifiable {
    let id: UUID
    let error: Error
    let retryHandler: () -> Void
}

struct ErrorHandler {
    
    private let id = UUID()
    
    func handle<T>(_ error: Error?, in view: T, retryHandler: @escaping () -> Void) -> AnyView where T : View {
        var presentation = error.map { Presentation(id: id, error: $0,retryHandler: retryHandler)}
        
        let binding = Binding(
            get: { presentation },
            set: { presentation = $0 }
        )
        
        return AnyView(view.alert(item: binding, content: makeAlert))
    }
    
    private func makeAlert(for presentation: Presentation) -> Alert {
        let error = presentation.error
        let praxisrufApiError = error as? PraxisrufApiError
        let message = praxisrufApiError?.localizedDescription ?? error.localizedDescription
        
        return Alert(
            title: Text("Fehler"),
            message: Text(message),
            dismissButton: .default(Text("Ok"), action: presentation.retryHandler)
        )
    }
}

struct ErrorHandlerEnvitonmentKey: EnvironmentKey {
    static var defaultValue: ErrorHandler = ErrorHandler()
}

extension EnvironmentValues {
    var errorHandler: ErrorHandler {
        get { self[ErrorHandlerEnvitonmentKey.self] }
        set { self[ErrorHandlerEnvitonmentKey.self] = newValue }
    }
}

struct ErrorEmittingViewModifier: ViewModifier {
    @Environment(\.errorHandler) var handler
    
    var error: Error?
    var retryHandler: () -> Void
    
    func body(content: Content) -> some View {
        handler.handle(error, in: content, retryHandler: retryHandler)
    }
}

extension View {
    func onError(_ error: Error?, retryHandler: @escaping () -> Void = {}) -> some View {
        modifier(ErrorEmittingViewModifier(error: error, retryHandler: retryHandler))
    }
}
