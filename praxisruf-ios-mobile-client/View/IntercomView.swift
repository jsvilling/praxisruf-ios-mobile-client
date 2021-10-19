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
        let clientName = UserDefaults.standard.string(forKey: "clientName") ?? "clientName"
        List(intercomVM.notificationTypes) { notificationType in
            Button(notificationType.title, action: {
                print("Send notification \(notificationType)")
            })
        }
        .navigationTitle(clientName)
        //.navigationBarBackButtonHidden(true)
        .onAppear {
            intercomVM.getNotificationTypes()
        }
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntercomView(intercomVM: IntercomViewModel(notificationTypes: NotificationType.data))
        }
        .navigationViewStyle(.stack)
    }
}
