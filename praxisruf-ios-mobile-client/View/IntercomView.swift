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
            Spacer()
            Text("notifications")
            ButtonGirdView(entries: $intercomVM.notificationTypes)
            Spacer()
            Text("intercom")
            ButtonGirdView(entries: $intercomVM.notificationTypes)
            Spacer()
        }
        .navigationTitle(clientName)
        //.navigationBarBackButtonHidden(true)
        .onAppear {
            intercomVM.getNotificationTypes()
        }
    }
}

struct ButtonGirdView: View {
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    @Binding var entries: [NotificationType]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(entries, id: \.self) { item in
                    Button(item.displayText, action: {
                        print("Send notification \(item)")
                    })
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
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
