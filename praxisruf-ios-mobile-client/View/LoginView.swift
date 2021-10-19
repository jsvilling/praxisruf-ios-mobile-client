//
//  ContentView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 17.10.21.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            WelcomeText()
            PraxisImage()
            LoginForm()
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

struct LoginForm: View {
    
    @StateObject private var loginVM = LoginViewModel()
        
    var body: some View {
        List {
            HStack {
                Image(systemName: "person")
                TextField(NSLocalizedString("username", comment: "username"), text: $loginVM.username)
                    .padding()
            }
            HStack {
                Image(systemName: "key")
                SecureField(NSLocalizedString("password", comment: "password"), text: $loginVM.password)
                        .padding()
            }
            NavigationLink(destination: ClientSelectView(), isActive: $loginVM.isAuthenticated) {EmptyView()}.hidden()
        }
        .listStyle(PlainListStyle())
        .frame(width: 440, height: 135)
        .padding(.bottom, 40)
        
        Button(action: loginVM.login) {
            Text(NSLocalizedString("login", comment: "login button text, all caps"))
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 60)
                .background(Color.accentColor)
                .cornerRadius(15.0)
        }
        .padding()
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
}
