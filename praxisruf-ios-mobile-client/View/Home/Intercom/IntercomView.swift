//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI

struct IntercomView: View {
    
    @StateObject var intercomVM = IntercomViewModel()

    var body: some View {
        VStack {
            Section(header: Text("notifications").font(.title2)) {
                ButtonGridView(entries: $intercomVM.notificationTypes, action: sendNotification)
            }
            Section(header: Text("intercom").font(.title2)) {
                ButtonGridView(entries: $intercomVM.notificationTypes, action: startCall)
            }
        }
        .onAppear {
            intercomVM.getNotificationTypes()
        }
    }
    
    func sendNotification(id: UUID) {
        intercomVM.sendNotification(notificationTypeId: id)
    }
    
    func startCall(id: UUID) {
        print("Starting call for: \(id)")
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        IntercomView(intercomVM: IntercomViewModel(notificationTypes: NotificationType.data))
    }
}


