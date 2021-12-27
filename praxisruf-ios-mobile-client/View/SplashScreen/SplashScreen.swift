//
//  SplashScreen.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 30.11.21.
//

import SwiftUI
import SwiftKeychainWrapper

struct SplashScreen: View {
    
    @State var redirectToLogin: Bool = false
    @State var redirectToClientSelect: Bool = false
    @State var redirectToHome: Bool = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: LoginView(), isActive: $redirectToLogin) {EmptyView()}.hidden()
            NavigationLink(destination: ClientSelectView(), isActive: $redirectToClientSelect) {EmptyView()}.hidden()
            NavigationLink(destination: HomeView(), isActive: $redirectToHome) {EmptyView()}.hidden()
        }.onAppear() {
            let username = KeychainWrapper.standard.string(forKey: UserDefaultKeys.userName)
            let password = KeychainWrapper.standard.string(forKey: UserDefaultKeys.password)
            let clientId = UserDefaults.standard.string(forKey: UserDefaultKeys.clientId)
            redirectToHome = username != nil && password != nil && clientId != nil
            if (!redirectToHome) {
                redirectToClientSelect = username != nil && password != nil
            }
            if (!redirectToClientSelect && !redirectToHome) {
                redirectToLogin = true
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
