//
//  ConnectionStatesView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 21.02.22.
//

import SwiftUI

struct ConnectionStatesView: View {
    
    @Binding var states: [String:(String, String)]
    
    var body: some View {
        
        if (states.count == 1) {
            StatusIndicator(status: self.states.first!.value.1)
        } else {
            ForEach(states.sorted { $0.key > $1.key }, id: \.key) { _, v in
                HStack {
                    Text("\(v.0)").font(.title)
                    Spacer()
                    StatusIndicator(status: v.1)
                }
                
            }
        }
    }
}

struct StatusIndicator: View {
    
    let status: String
    
    var body: some View {
        switch(status) {
            case "CONNECTED":
                StatusIcon(icon: "checkmark.circle.fill", color: .green)
            case "REQUESTED":
                StatusIcon(icon:"hourglass.circle", color: .gray)
            case "DECLINED":
                StatusIcon(icon:"x.circle.fill", color: .red)
            case "DISCONNECTED":
                StatusIcon(icon:"x.circle.fill", color: .red)
            case "UNAVAILABLE":
                StatusIcon(icon:"x.circle.fill", color: .red)
            default:
                Image(systemName:"questionmark.circle.fill")
        }
    }
}

struct StatusIcon: View {
    let icon: String
    let color: Color
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .frame(width: 25, height: 25)
            .foregroundColor(color)
    }
}

struct ConnectionStatesView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatesView(states: .constant([:]))
    }
}
