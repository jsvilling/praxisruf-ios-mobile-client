//
//  CallActionButton.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import SwiftUI

struct CallActionButton: View {
    private let image: String
    private var width: CGFloat?
    private var height: CGFloat?
    private let activeColor: Color
    private let inactiveColor: Color
    private let action: (Bool) -> Void
    
    @State var pressed: Bool = false
    
    init (image: String, width: CGFloat? = 50, height: CGFloat? = 25, tapped: Color = Color.black, untapped: Color = Color.gray, action: @escaping (Bool) -> Void) {
        self.image = image
        self.width = width
        self.height = height
        self.activeColor = tapped
        self.inactiveColor = untapped
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.pressed.toggle()
            self.action(self.pressed)
        }) {
            ZStack {
                Image(systemName: self.image)
                    .resizable()
                    .frame(width: width, height: height)
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: 100, height: 100)
            .foregroundColor(Color.black)
            .background(self.pressed ? activeColor : inactiveColor)
            .clipShape(Circle())
    }
}

struct CallActionButton_Previews: PreviewProvider {
    static var previews: some View {
        CallActionButton(image: "phone.down") { r in }
    }
}
