//
//  ContentView.swift
//  praxisruf-ios-mobile-client
//
//  Created by user on 17.10.21.
//

import SwiftUI

struct LoginView: View {
    
    @State var username = ""
    @State var password = ""
    @State var isLoggedIn = false
    
    var body: some View {
        VStack {
            WelcomeText()
            PraxisImage()
            
            List {
                HStack {
                    Image(systemName: "person")
                    TextField(NSLocalizedString("username", comment: "username"), text: $username)
                        .padding()
                }
                HStack {
                    Image(systemName: "key")
                    SecureField(NSLocalizedString("password", comment: "password"), text: $password)
                            .padding()
                }
                NavigationLink(destination: IntercomView(), isActive: $isLoggedIn) {EmptyView()}.hidden()
            }
            .listStyle(PlainListStyle())
            .frame(width: 440, height: 135)
            .padding(.bottom, 40)
            
            Button(action: {
                print("Logging in with \(self.username) \(self.password)")
                self.isLoggedIn = true
            }) {
                Text(NSLocalizedString("login", comment: "login button text, all caps"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.accentColor)
                    .cornerRadius(15.0)
            }
        }
        .padding()
    }
}

struct WelcomeText: View {
    var body: some View {
        Text(NSLocalizedString("welcome", comment: "welcome message"))
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct PraxisImage: View {
    var body: some View {
        Image("tooth")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
                .previewDevice("iPad (9th generation)")
            }
        .navigationViewStyle(.stack)
        .previewDevice("iPad (9th generation)")

    }
    
}
