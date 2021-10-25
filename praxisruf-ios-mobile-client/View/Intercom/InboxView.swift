//
//  InboxView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI

struct InboxView: View {
    
    var inboxItems: [InboxItem]
    
    var body: some View {
        VStack {
            List {
                ForEach(inboxItems) { item in
                    InboxItemView(inboxItem: item)
                }
            }
            .listRowInsets(EdgeInsets())
        }
    }
}

struct InboxItemView: View {
    
    let inboxItem: InboxItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ItemIndicator
            Image(systemName: inboxItem.type)
                .padding(.leading)
                .frame(width: 25, height: 40, alignment: .center)
            VStack(alignment: .leading) {
                Text(inboxItem.title)
                     .font(.headline)
                     .lineLimit(1)
                     .truncationMode(.tail)
                
                Text(inboxItem.body)
                    .font(.body)
                    .opacity(0.54)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack {
                Text("Date Placeholder")
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
    }
}

private var ItemIndicator: some View {
    Rectangle()
        .fill(Color.blue)
        .frame(width: 4, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8))
}


struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(inboxItems: InboxItem.data)
    }
}
