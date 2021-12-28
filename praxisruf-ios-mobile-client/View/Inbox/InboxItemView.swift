//
//  InboxItemView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import SwiftUI

struct InboxItemView: View {
    
    @Binding var inboxItem: InboxItem
    let action: (InboxItem) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ItemIndicator
            Image(systemName: inboxItem.type)
                .padding(.leading)
                .frame(width: 25, height: 40, alignment: .center)
            VStack(alignment: .leading) {
                Text("\(inboxItem.sender)")
                     .font(.headline)
                     .lineLimit(1)
                     .truncationMode(.tail)
                
                Text(inboxItem.fullBody())
                    .font(.body)
                    .opacity(0.54)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack {
                Text(inboxItem.receivedAt.toString())
                    .font(.caption)
                    .opacity(0.54)
                
                if !inboxItem.ack {
                    Text("")
                        .frame(width: 8, height: 8)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .padding(.top)
                }
            }
        }
        .padding()
        .onTapGesture {
            action(inboxItem)
        }
    }
}

private var ItemIndicator: some View {
    Rectangle()
        .fill(Color.red)
        .frame(width: 4, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8))
}

struct InboxItemView_Previews: PreviewProvider {
    static var previews: some View {
        InboxItemView(inboxItem: .constant(InboxItem.data[0]), action: noop)
    }
    
    static func noop(i: InboxItem) {}
}
