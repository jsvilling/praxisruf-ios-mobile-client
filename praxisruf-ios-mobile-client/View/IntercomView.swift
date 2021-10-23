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

        VStack {
            Section(header: Text("notifications").font(.title2)) {
                ButtonGirdView(entries: $intercomVM.notificationTypes, action: sendNotification)
            }
            Section(header: Text("intercom").font(.title2)) {
                ButtonGirdView(entries: $intercomVM.notificationTypes, action: startCall)
            }
        }
        .navigationTitle(clientName)
        //.navigationBarBackButtonHidden(true)
        .onAppear {
            intercomVM.getNotificationTypes()
        }
    }
    
    func sendNotification(id: UUID) {
        print("Sending notification for: \(id)")
    }
    
    func startCall(id: UUID) {
        print("Starting call for: \(id)")
    }
}

struct ButtonGirdView: View {
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    @Binding var entries: [NotificationType]
    let action: (UUID) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(entries, id: \.self) { item in
                    IntercomButton(item: item, action: action)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
    }
}

struct IntercomButton: View {
    let item: IntercomItem
    let action: (UUID) -> Void
    
    var body: some View {
        Button(item.displayText, action: {
            action(item.id)
        })
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
