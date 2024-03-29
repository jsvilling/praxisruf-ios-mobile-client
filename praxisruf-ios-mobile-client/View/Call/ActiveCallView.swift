//
//  ActiveCallView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import Foundation
import SwiftUI

struct ActiveCallView: View {
    
    @StateObject var callService: CallService
    private let audioPlayer: AudioPlayer = AudioPlayer()
    
    var body: some View {
        VStack {
            Text(callService.callPartnerName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 50)
            
            ConnectionStatesView(states: $callService.states)
                .padding(.horizontal, 300)
                .padding(.bottom, 50)

            HStack {
                Spacer()
                CallActionButton(image: "mic.slash", width: 35, height: 40, action: callService.toggleMute)
                CallActionButton(image: "speaker.slash", width: 35, height: 40, action: callService.toggleSpeaker)
                CallActionButton(image: "phone.down", tapped: Color.red, untapped: Color.red, action: endCall)
                Spacer()
            }
        }
        .onAppear() {
            if (self.callService.callTypeId == "") {
                audioPlayer.playAppSound(name: "call" )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    self.callService.acceptPending()
                }
            } else {
                self.callService.startCall()
            }
        }
    }
        
    private func endCall(_ b: Bool) {
        callService.endCall()
    }
}

struct ActiveCallView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveCallView(callService: CallService(settings: Settings()))
    }
}
