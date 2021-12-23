//
//  ButtonGridView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import SwiftUI

struct ButtonGridView<I>: View where I: IntercomItem, I: Hashable {
    
    let columns = [GridItem(.adaptive(minimum: 200))]
    @Binding var entries: [I]
    let action: (I) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(entries, id: \.self) { item in
                    IntercomButton(item: item, action: action)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .frame(maxHeight: 300)
    }
}

struct ButtonGridView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonGridView(entries: .constant(NotificationType.data), action: noop)
    }
    static func noop(item: NotificationType) {}
}
