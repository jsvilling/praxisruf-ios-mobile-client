//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation

class PraxisrufApi : ObservableObject {
    
    @Published var token = String()
    
    let baseUrlValue = "https://www.praxisruf.ch/api"
    
    func login(username: String, password: String) {
        print("Logging in with: \(username) \(password)")
        guard let url = URL(string: "\(baseUrlValue)/users/login") else {
            print("Invalid url")
            return
        }

        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response,     error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                print("Error reponse code ")
                return
            }
            
            guard let receivedAuthToken = httpResponse.value(forHTTPHeaderField: "Authorization") else {
                print("Empty token")
                return
            }
            
            print(receivedAuthToken)
            
            guard let da = data else {
                return
            }
            
            print(da)
            
            DispatchQueue.main.async {
                self.token = receivedAuthToken
            }
        }.resume()
    }
}
