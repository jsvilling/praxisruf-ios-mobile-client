//
//  InboxView.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 18.10.21.
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        VStack {
            Text("notifications")
            Text("intercom")
        }
        .navigationTitle("inbox")
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InboxView()
        }
        .navigationViewStyle(.stack)
    }
}
