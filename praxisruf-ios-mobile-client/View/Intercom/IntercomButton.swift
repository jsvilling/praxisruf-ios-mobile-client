//
//  IntercomButton.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 25.10.21.
//

import SwiftUI

struct IntercomButton<I>: View where I: IntercomItem {
    let item: I
    let action: (I) -> Void
    
    var body: some View {
  
        Button(action: onTap) {
            Text(item.displayText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
        }
        .scaleEffect()
        .frame(width: 200, height: 60)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(#colorLiteral(red: 0.76, green: 0.81, blue: 0.92, alpha: 1)), radius: 20, x: 20, y: 20)
        .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 20, x: -20, y: -20)
    }
    
    private func onTap() {
        action(item)
    }
}

struct IntercomButton_Previews: PreviewProvider {
    static var previews: some View {
        IntercomButton<NotificationType>(item: NotificationType.data[0], action: noop)
    }
    
    static func noop(id: NotificationType) {}
}
