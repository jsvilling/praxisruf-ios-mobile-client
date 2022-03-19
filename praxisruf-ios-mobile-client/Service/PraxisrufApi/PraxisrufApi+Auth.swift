//
//  PraxisrufApi+Auth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 19.10.21.
//

import Foundation

/// Extension for PraxisrufApi to enable login with basic authentication.
///
/// This service does not use the http methods of PraxisrufApi.
/// The login request cannot be made with an token as this token is only received after the login.
extension PraxisrufApi {
    
    /// Creates a http get request for "<baseUrl>/users/login"
    /// The request will be created with an basic auth header containing the given username and password.
    ///
    /// On completion of the request the completion callback is called with either the received token or an error.
    ///
    /// This is used by the LoginView upon login as well as the IntercomView to refresh the token regularly.
    func login(username: String, password: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        let url = URL(string: "\(PraxisrufApi.httpBaseUrlValue)/users/login")!
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.custom(errorMessage: "Error Response received")))
                return
            }
            
            guard let token = httpResponse.value(forHTTPHeaderField: "Authorization") else {
                completion(.failure(.custom(errorMessage: "No token received")))
                return
            }
            completion(.success(token))
        }.resume()
    }
}
