//
//  InboxView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI
import Firebase

struct InboxView: View {
    
    @StateObject var inbox = Inbox.shared
    
    var body: some View {
        VStack {
            List {
                ForEach($inbox.content) { item in
                    InboxItemView(inboxItem: item, action: acknowledge)
                }
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    private func acknowledge(item: InboxItem) {
        guard let i = inbox.content.firstIndex(where: {$0.id == item.id}) else {
            return
        }
        inbox.content[i].ack = true
    }
    
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(inbox: Inbox(values: InboxItem.data))
    }
}
