//
//  ConnectionStatesView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 21.02.22.
//

import SwiftUI

struct ConnectionStatesView: View {
    
    @Binding var states: [String:(String, ConnectionStatus)]
    
    var body: some View {
        
        if (states.count == 1) {
            StatusIndicator(status: self.states.first!.value.1)
        } else {
            ForEach(states.sorted { $0.key > $1.key }, id: \.key) { _, v in
                HStack {
                    Text("\(v.0)")
                    Spacer()
                    StatusIndicator(status: v.1)
                }
                
            }
        }
    }
}

struct StatusIndicator: View {
    
    let status: ConnectionStatus
    
    var body: some View {
        switch(status) {
            case .CONNECTED:
                StatusIcon(icon: "checkmark.circle.fill", color: .green)
            case .PROCESSING:
                StatusIcon(icon:"hourglass.circle", color: .gray)
            case .DISCONNECTED:
                StatusIcon(icon:"x.circle.fill", color: .red)
            case .UNKNOWN:
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
