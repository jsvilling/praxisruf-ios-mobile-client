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
                CallActionButton(image: "mic.slash", width: 40, height: 35, action: callService.toggleMute)
                CallActionButton(image: "speaker.slash", width: 35, height: 35, action: {})
                CallActionButton(image: "phone.down", action: callService.endCall)
                Spacer()
            }
        }
        .onAppear() {
            if (self.callService.callTypeId == "") {
                print("Incomming call")
                // The callTypeId is only set it the client is the one initiating the call
                // This solution is only a temporary workaround and will not work in the long run
                // TODO: Proper state handling for call direction
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
