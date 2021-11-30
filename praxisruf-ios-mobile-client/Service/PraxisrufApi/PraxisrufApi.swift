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
        
    func get(_ subUrl: String, task: @escaping (URLRequest) -> Void) {
        authorizedRequest(subUrl, task: task)
    }
    
    func post(_ subUrl: String, task: @escaping (URLRequest) -> Void) {
        authorizedRequest(subUrl, method: "POST", task: task)
    }
    
    func delete(_ subUrl: String, task: @escaping (URLRequest) -> Void) {
        authorizedRequest(subUrl, method: "DELETE", task: task)
    }
    
    private func authorizedRequest(_ subUrl: String, method: String = "GET", task: @escaping (URLRequest) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)\(subUrl)") else {
            fatalError("Invalid url configuration")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        let defaults = UserDefaults.standard
        guard let authToken = defaults.string(forKey: UserDefaultKeys.authToken) else  {
            fatalError("No authorization found")
        }
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        task(request)
    }
    

}
