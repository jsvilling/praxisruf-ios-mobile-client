//
//  ContentView.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 17.10.21.
//

import SwiftUI
import SwiftKeychainWrapper

struct LoginView: View {
    
    @State private var username: String = "admin"
    @State private var password: String = "admin"
    @StateObject private var authService = AuthService()
    
    var body: some View {

        VStack {
            // Welcome Text
            Text(NSLocalizedString("welcome", comment: "welcome message"))
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            // Image
            Image("tooth")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(150)
            
            // Login Form
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
                NavigationLink(destination: ClientSelectView(), isActive: $authService.isAuthenticated) {EmptyView()}.hidden()
            }
            .listStyle(PlainListStyle())
            .frame(width: 440, height: 135)
            .padding(.bottom, 40)
            
            Button(action: {authService.login(username, password)} ) {
                Text(NSLocalizedString("login", comment: "login button text, all caps"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.accentColor)
                    .cornerRadius(15.0)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .onError(authService.error, retryHandler: {authService.login(username, password)})
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
