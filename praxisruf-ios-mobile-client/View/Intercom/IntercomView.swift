//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI
import AVFoundation

struct IntercomView: View {
    
    @Binding var configuration: Configuration
    @StateObject var intercomVM = IntercomViewModel()

    var body: some View {
        VStack {
            Section(header: Text("intercom").font(.title2)) {
                ButtonGridView(entries: $configuration.notificationTypes, action: startCall)
                RetryAlert(isPresented: $intercomVM.hasErrorResponse, id: $intercomVM.notificationSendResult.notificationId, action: retryNotification)
            }
            
            Section(header: Text("notifications").font(.title2)) {
                ButtonGridView(entries: $configuration.notificationTypes, action: sendNotification)
            }
        }
        .navigationBarBackButtonHidden(true)

    }
    
    func sendNotification(id: UUID) {
        intercomVM.sendNotification(notificationTypeId: id)
    }
    
    func retryNotification(id: UUID) {
        intercomVM.retryNotification(notificationId: intercomVM.notificationSendResult.notificationId)
    }
    
    func startCall(id: UUID) {
        print("Starting call for: \(id)")
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        IntercomView(configuration: .constant(Configuration.data), intercomVM: IntercomViewModel(notificationTypes: NotificationType.data))
    }
}


