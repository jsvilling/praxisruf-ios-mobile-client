//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 18.10.21.
//

import SwiftUI

struct IntercomView: View {
    var body: some View {
        VStack {
            Text("notifications")
            Text("intercom")
        }
        .navigationTitle("praxisruf")
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntercomView()
        }
        .navigationViewStyle(.stack)
    }
}
