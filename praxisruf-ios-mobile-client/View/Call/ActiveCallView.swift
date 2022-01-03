//
//  ActiveCallView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import SwiftUI

struct ActiveCallView: View {
    
    @StateObject var callService: CallService
    
    var body: some View {
        VStack {
            Text(callService.callPartnerName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 50)
            
            
            ForEach(callService.states.sorted { $0.key > $1.key }, id: \.key) { _, v in
                Text("\(v.0): \(v.1)")
                    .padding(.bottom, 50)
            }

            HStack {
                Spacer()
                CallActionButton(image: "mic.slash", width: 35, height: 40, action: callService.toggleMute)
                CallActionButton(image: "speaker.slash", width: 35, height: 40, action: {})
                CallActionButton(image: "phone.down", tapped: Color.red, untapped: Color.red, action: callService.endCall)
                Spacer()
            }
        }
        .onAppear() {
            if (self.callService.callTypeId != "") {
                self.callService.startCall()
            }
        }
    }
}

struct ActiveCallView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveCallView(callService: CallService())
    }
}
