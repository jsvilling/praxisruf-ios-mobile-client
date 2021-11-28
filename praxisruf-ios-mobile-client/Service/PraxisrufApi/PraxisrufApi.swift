//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation

class PraxisrufApi {
    
    enum PraxisrufApiError: Error {
        case invalidCredentials
        case custom(errorMessage: String)
    }
        
    let baseUrlValue = "https://www.praxisruf.ch/api"
    
    func authorize(task: @escaping (String?) -> Void) {        
        let defaults = UserDefaults.standard
        let authToken = defaults.string(forKey: UserDefaultKeys.authToken)
        task(authToken)
    }
    
    func authorizedRequest(subUrl: String, task: @escaping (URLRequest) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)\(subUrl)") else {
            print("Invalid url configuration")
            return
        }
        var request = URLRequest(url: url)
        let defaults = UserDefaults.standard
        let authToken = defaults.string(forKey: UserDefaultKeys.authToken)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        task(request)
    }
}
