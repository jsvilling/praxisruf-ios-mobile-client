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
    
    @State private var loginPressed = false
    @State private var showClientSelection = false
    @StateObject private var auth = AuthService()
    
    private func login() {
        auth.login(username, password)
        loginPressed = true
    }
    
    var body: some View {
        
        VStack {
            
            NavigationLink(destination: ClientSelectView().environmentObject(auth), isActive: $showClientSelection) {EmptyView()}.hidden()
            
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

            }
            .listStyle(PlainListStyle())
            .frame(width: 440, height: 135)
            .padding(.bottom, 40)
            
            Button(action: login ) {
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
            .onChange(of: auth.isAuthenticated) { v in
                self.showClientSelection = self.loginPressed && v
            }
            .onError(auth.error, retryHandler: login)
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

