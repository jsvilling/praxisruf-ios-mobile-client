//
//  LoginViewModel.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    var username: String = "admin"
    var password: String = "admin"
    @Published var isAuthenticated: Bool = false
    
    func login() {
        let defaults = UserDefaults.standard
        PraxisrufApi().login(username: username, password: password) { result in
            switch result {
                case .success (let token):
                    defaults.setValue(token, forKey: "jwt")
                    defaults.setValue(self.username, forKey: "username")
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
}
