//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI
import AVFoundation

struct IntercomView: View {
    
    let keepAliveSignalingConnection = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @Binding var configuration: Configuration
    @StateObject var notificationService = NotificationService()
    @StateObject var callService = CallService()

    @State var isCallStarted = false
    
    var body: some View {
        VStack {
            Section(header: Text("intercom").font(.title2)) {
                ButtonGridView(entries: $configuration.callTypes, action: callService.initCall)
            }
            
            Section(header: Text("notifications").font(.title2)) {
                ButtonGridView(entries: $configuration.notificationTypes, action: notificationService.sendNotification)
                RetryAlert(isPresented: $notificationService.hasErrorResponse, id: $notificationService.notificationSendResult.notificationId, action: notificationService.retryNotification)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: callService.listen)
        .onReceive(keepAliveSignalingConnection, perform: callService.ping)
        .fullScreenCover(isPresented: $callService.active) {
                ActiveCallView(callService: callService)
        }
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        IntercomView(configuration: .constant(Configuration.data), notificationService: NotificationService())
    }
}


