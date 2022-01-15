//
//  SplashScreen.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 30.11.21.
//

import SwiftUI
import SwiftKeychainWrapper

struct InitialView: View {

    @EnvironmentObject var auth: AuthService
    @State var isLoginDataAbsent = false
    @State var isLoggedIn = false

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
            
            NavigationLink(destination: LoginView().environmentObject(auth), isActive: $isLoginDataAbsent) {EmptyView()}.hidden()
            NavigationLink(destination: HomeView().environmentObject(auth), isActive: $isLoggedIn) {EmptyView()}.hidden()
        }.onAppear() {
            let username = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName)
            let password = KeychainWrapper.standard.string(forKey: UserDefaultKeys.password)
            let clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)
            
            if (username == nil || password == nil || clientId == nil) {
                self.isLoginDataAbsent = true
            } else {
                auth.login(username!, password!)
                self.isLoggedIn = true
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}
