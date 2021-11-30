//
//  RetryAlert.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 30.11.21.
//

import SwiftUI

struct RetryAlert: View {
    
    @Binding var isPresented: Bool
    @Binding var id: UUID
    let action: (UUID) -> Void
    
    var body: some View {
        VStack {}
        .alert(isPresented: $isPresented) {
            Alert(
             title: Text("Fehler."),
             message: Text("Die Benachrichtigung konnte nicht an alle Empfänger übermittelt werden"),
             primaryButton: .default(Text("Retry"), action: confirm),
             secondaryButton: .destructive(Text("Cancel"))
            )
        }
    }
    
    func confirm() {
        action(id)
    }
}

struct RetryAlert_Previews: PreviewProvider {
    static var previews: some View {
        RetryAlert(isPresented: .constant(true), id: .constant(NotificationType.data[0].id)) { id in
            print(id)
        }
    }
}
