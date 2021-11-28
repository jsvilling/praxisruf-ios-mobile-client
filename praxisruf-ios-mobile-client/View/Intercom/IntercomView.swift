//
//  IntercomHomeView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import SwiftUI
import AVFoundation

struct IntercomView: View {
    
    @StateObject var intercomVM = IntercomViewModel()

    var body: some View {
        VStack {
            Section(header: Text("intercom").font(.title2)) {
                ButtonGridView(entries: $intercomVM.notificationTypes, action: startCall)
            }
            .alert(isPresented: $intercomVM.hasErrorResponse) {
                       Alert(title: Text("Fehler."), message: Text("Die Benachrichtigung konnte nicht an alle Empfänger übermittelt werden"))
                   }
            Section(header: Text("notifications").font(.title2)) {
                ButtonGridView(entries: $intercomVM.notificationTypes, action: sendNotification)
            }
        }
        .onAppear {
            RegistrationService().register()
            intercomVM.getNotificationTypes()
        }
        .navigationBarBackButtonHidden(true)

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


