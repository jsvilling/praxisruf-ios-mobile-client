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
                ButtonGridView(entries: $configuration.callTypes, action: startCall)
            }
            
            Section(header: Text("notifications").font(.title2)) {
                ButtonGridView(entries: $configuration.notificationTypes, action: intercomVM.sendNotification)
                RetryAlert(isPresented: $intercomVM.hasErrorResponse, id: $intercomVM.notificationSendResult.notificationId, action: intercomVM.retryNotification)
            }
        }
        .navigationBarBackButtonHidden(true)

    }
        
    func startCall(id: UUID) {
        print("Starting call for: \(id)")
    }
}

struct IntercomHomeView_Previews: PreviewProvider {
    static var previews: some View {
        IntercomView(configuration: .constant(Configuration.data), intercomVM: IntercomViewModel())
    }
}


