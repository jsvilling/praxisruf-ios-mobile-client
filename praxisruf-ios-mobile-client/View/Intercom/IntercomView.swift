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
    
    @Environment(\.scenePhase) var scenePhase
    @Binding var configuration: Configuration
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var settings: Settings
    @StateObject var notificationService: NotificationService = NotificationService()
    @StateObject var callService: CallService = CallService()
    
    var body: some View {
        VStack {
            Section(header: HStack {
                Text("intercom").font(.title2).padding(.leading, 50)
                Spacer()
            }) {
                ButtonGridView(entries: $configuration.callTypes, action: callService.initCall)
                    .onError(callService.error)
            }
            
            Section(header: HStack {
                Text("notifications").font(.title2).padding(.leading, 50)
                Spacer()
            }) {
                ButtonGridView(entries: $configuration.notificationTypes, action: notificationService.sendNotification)
                    .onError(notificationService.error)
                RetryAlert(isPresented: $notificationService.hasDeliveryFailed, id: $notificationService.notificationSendResult.notificationId, action: notificationService.retryNotification)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(keepAliveSignalingConnection, perform: pingSingalingConnection)
        .onAppear(perform: self.activate)
        .onChange(of: scenePhase, perform: self.onPhaseChange)
        .fullScreenCover(isPresented: $callService.active) {
            ActiveCallView(callService: callService)
        }
    }
    
    private func activate() {
        self.notificationService.settings = settings
        self.callService.settings = settings
        self.callService.listen()
    }
    
    private func onPhaseChange(newPhase: ScenePhase) {
        if (newPhase == .inactive || newPhase == .background) {
            self.callService.disconnect()
        } else if (newPhase == .active) {
            self.activate()
        }
    }
    
    private func pingSingalingConnection(_ input: Any? = nil) {
        if (auth.isAuthenticated) {
            callService.ping()
        } 
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        IntercomView(configuration: .constant(Configuration.data))
    }
}
