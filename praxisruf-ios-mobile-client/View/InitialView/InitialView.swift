//
//  SplashScreen.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 30.11.21.
//

import SwiftUI
import SwiftKeychainWrapper

struct InitialView: View {

    @EnvironmentObject var settings: Settings
    @EnvironmentObject var auth: AuthService

    @State var showLogin = false
    @State var showHome = false

    var body: some View {
        
        let loginBinding = Binding(
            get: { self.showLogin },
            set: {
                self.showLogin = $0 && !auth.isAuthenticated
            }
        )
        
        let homeBinding = Binding(
                    get: { self.showHome },
                    set: {
                        self.showHome = $0 && auth.isAuthenticated
                    }
                )
        
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
            
            NavigationLink(destination: HomeView().environmentObject(auth), isActive: homeBinding) {EmptyView()}.hidden()
            NavigationLink(destination: LoginView().environmentObject(auth), isActive: loginBinding) {EmptyView()}.hidden()
          
        }.onAppear() {
            let username = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName)
            let password = KeychainWrapper.standard.string(forKey: UserDefaultKeys.password)
            
            if (username == nil || password == nil) {
                self.showLogin = true
            } else {
                auth.login(username!, password!)
                self.showHome = true
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}
