//
//  CallActionButton.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.12.21.
//

import SwiftUI

struct CallActionButton: View {
    private let image: String
    private var width: CGFloat? = 50
    private var height: CGFloat? = 25
    private let action: () -> Void
    
    init (image: String, width: CGFloat? = 50, height: CGFloat? = 25, action: @escaping () -> Void) {
        self.image = image
        self.width = width
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100, alignment: .center)
                
                Image(systemName: self.image)
                    .resizable()
                    .frame(width: width, height: height)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct CallActionButton_Previews: PreviewProvider {
    static var previews: some View {
        CallActionButton(image: "phone.down", action: {})
    }
}
