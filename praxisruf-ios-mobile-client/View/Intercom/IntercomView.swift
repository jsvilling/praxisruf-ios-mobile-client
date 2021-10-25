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
                ButtonGirdView(entries: $intercomVM.notificationTypes, action: sendNotification)
            }
            Section(header: Text("intercom").font(.title2)) {
                ButtonGirdView(entries: $intercomVM.notificationTypes, action: startCall)
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

struct ButtonGirdView: View {
    
    let columns = [GridItem(.adaptive(minimum: 200))]
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
            .padding(.top)
        }
        .frame(maxHeight: 300)
    }
}

struct IntercomButton: View {
    let item: IntercomItem
    let action: (UUID) -> Void
    
    var body: some View {
  
        Text(item.displayText)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .frame(width: 200, height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color(#colorLiteral(red: 0.76, green: 0.81, blue: 0.92, alpha: 1)), radius: 20, x: 20, y: 20)
            .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 20, x: -20, y: -20)
            .onTapGesture {
                action(item.id)
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
