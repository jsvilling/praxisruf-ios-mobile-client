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
    private let tapped: Color
    private let untapped: Color
    private let action: () -> Void
    
    init (image: String, width: CGFloat? = 50, height: CGFloat? = 25, tapped: Color = Color.black, untapped: Color = Color.gray, action: @escaping () -> Void) {
        self.image = image
        self.width = width
        self.height = height
        self.tapped = tapped
        self.untapped = untapped
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            ZStack {
                Image(systemName: self.image)
                    .resizable()
                    .frame(width: width, height: height)
                    .foregroundColor(Color.white)
            }
        }.buttonStyle(GradientButtonStyle(tapped: tapped, untapped: untapped))
    }
}

struct GradientButtonStyle: ButtonStyle {
    
    let tapped: Color
    let untapped: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
       
        configuration.label
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.black)
                    .background(configuration.isPressed ? tapped : untapped)
                    .clipShape(Circle())
    }
}

struct CallActionButton_Previews: PreviewProvider {
    static var previews: some View {
        CallActionButton(image: "phone.down", action: {})
    }
}
