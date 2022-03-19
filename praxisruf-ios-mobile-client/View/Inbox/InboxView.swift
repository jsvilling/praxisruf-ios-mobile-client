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
                    InboxItemView(inboxItem: item, action: remove)
                }
                HStack {
                    Spacer()
                    Button("emptyInbox") {
                        DispatchQueue.main.async {
                            inbox.clear()
                        }
                    }
                    Spacer()
                }
            }
            .listRowInsets(EdgeInsets())
            .onConditionReplaceWith(inbox.content.isEmpty) {
                    VStack {
                        Image(systemName: "envelope.open")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 50)
                            .padding(.bottom, 25)
                           
                        Text("noInboxItems")
                    }.opacity(0.33)
                }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func compareItems(_ i1: InboxItem, _ i2: InboxItem) -> Bool {
        return i1.receivedAt < i2.receivedAt
    }
    
    private func remove(item: InboxItem) {
        guard let i = inbox.content.firstIndex(where: {$0.id == item.id}) else {
            return
        }
        inbox.content[i].ack = true
        inbox.content.remove(at: i)
    }
}



struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(inbox: Inbox(values: InboxItem.data))
    }
}
