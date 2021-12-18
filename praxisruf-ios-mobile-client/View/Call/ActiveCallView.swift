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
                CallActionButton(image: "mic.slash", width: 40, height: 35, action: {})
                CallActionButton(image: "speaker.slash", width: 35, height: 35, action: {})
                CallActionButton(image: "phone.down", action: callService.endCall)
                Spacer()
            }
        }
        .onAppear() {
            self.callService.startCall()
        }
    }
}

struct ActiveCallView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveCallView(callService: CallService())
    }
}
