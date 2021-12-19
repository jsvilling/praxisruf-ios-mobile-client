//
//  ActiveCallView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import SwiftUI

struct ActiveCallView: View {
    
    let callService: CallService
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                CallActionButton(image: "mic.slash", width: 35, height: 40, action: callService.toggleMute)
                CallActionButton(image: "speaker.slash", width: 35, height: 40, action: {})
                CallActionButton(image: "phone.down", tapped: Color.red, untapped: Color.red, action: callService.endCall)
                Spacer()
            }
        }
        .onAppear() {
            if (self.callService.callTypeId == "RECEIVING") {
                print("Incomming call")
            } else {
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
