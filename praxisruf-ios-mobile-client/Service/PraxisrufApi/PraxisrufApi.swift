//
//  PraxisrufApi.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation
import SwiftKeychainWrapper

/// This service allows making HTTP calls to tha praxisruf api.
///
/// Base URLs for HTTP and Websocket connections are loaded from the bundle configuration.
///
/// This service provides methods to make get, post and delete HTTP Calls.
/// These calls will automatically be made with an authorization header containing a auth token seved in the keychain.
/// This auth token is saved to the KeyChain by the Service Auth.
///
/// In addition to the HTTP-Verb methods the methods http and download are offered.
/// The http method can be used to create an arbitrary http request.
/// The download method can be used to download a file via a HTTP get request.
///
/// PraxisrufApi is used by the service classes in this app.
/// It is further extended by extension classes in the same package.
/// These extension classes provide methods to make use case specific requests using the http verb methods in the base class.
class PraxisrufApi {
    
    /// Dummy type to facilitate empty responses
    struct Nothing : Decodable {}
    static let httpBaseUrlValue = Bundle.main.object(forInfoDictionaryKey: "BaseUrlHttps") as! String
    static let webSocketBaseUrlValue = Bundle.main.object(forInfoDictionaryKey: "BaseUrlWss") as! String
    
    /// Makes a http get request for the url "<baseUrl><subUrl>"
    ///
    /// The given completion callback will be called upon completion of the request with either an error or a result of type T.
    /// Type T can be generic, but must implement Decodable.
    /// PraxisrufApi will convert the response body to type T. If this is not possible, the request completes with an error. 
    func get<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, completion: completion)
    }
    
    /// Makes a http post request for the url "<baseUrl><subUrl>"
    ///
    /// If the optional Data parameter is given it will be used as http request body.
    ///
    /// The given completion callback will be called upon completion of the request with either an error or a result of type T.
    /// Type T can be generic, but must implement Decodable.
    /// PraxisrufApi will convert the response body to type T. If this is not possible, the request completes with an error.
    func post<T>(_ subUrl: String, body: Data? = nil, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, method: "POST", body: body, completion: completion)
    }
    
    /// Makes a http delete request for the url "<baseUrl><subUrl>"
    ///
    /// The given completion callback will be called upon completion of the request with either an error or a result of type T.
    /// Type T can be generic, but must implement Decodable.
    /// PraxisrufApi will convert the response body to type T. If this is not possible, the request completes with an error.
    func delete<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, method: "DELETE", completion: completion)
    }
    
    /// Makes a http request with the given method for the url "<baseUrl><subUrl>"
    /// If no method is provided, a http get request is made.
    ///
    /// If the optional Data parameter is given it will be used as http request body.
    ///
    /// These request will automatically be made with an authorization header containing a auth token seved in the keychain.
    /// This auth token is saved to the keychain by the Service Auth.
    /// If no token is found in the keychain the requests completes with an error.
    ///
    /// The given completion callback will be called upon completion of the request with either an error or a result of type T.
    /// Type T can be generic, but must implement Decodable.
    /// PraxisrufApi will convert the response body to type T. If this is not possible, the request completes with an error.
    private func http<T>(_ subUrl: String, method: String = "GET", body: Data? = nil, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        let url = URL(string: "\(PraxisrufApi.httpBaseUrlValue)\(subUrl)")!
        
        /// Retrieve token or fail with error
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return
        }
        
        /// Construct http request with url and auth token
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        /// Set http request body if present
        if (body != nil) {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        /// Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            /// Complete with error because response code was faulty
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.errorResponse))
                return
            }
            
            /// Check if response data is present or fail with error
            guard let responsData = data else {
                 completion(.failure(.invalidData))
                 return
             }
            
            /// Decpde response body into given generic type T
            ///  Complete with error if conversion fails
            guard let result = try? JSONDecoder().decode(T.self, from: responsData) else {
                completion(.failure(.invalidData))
                return
            }
        
            /// Complete with success
            completion(.success(result))
        }.resume()
    }
    
    /// Makes a http get request with the given method for the url "<baseUrl><subUrl>"
    /// The request is executed as a download task and the downloaded file is stored in a temp directory.
    ///
    /// The provided completion callback will be called with an error if the request fails or with the
    /// URL of the file in the temp directory if the download succeeded.
    ///
    /// These request will automatically be made with an authorization header containing a auth token seved in the keychain.
    /// This auth token is saved to the keychain by the Service Auth.
    /// If no token is found in the keychain the requests completes with an error.
    func download(_ subUrl: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        /// Construct URL
        guard let url = URL(string: "\(PraxisrufApi.httpBaseUrlValue)\(subUrl)") else {
            completion(.failure(.invalidData))
            return
        }
                
        /// Retrieve authToken or complete with error
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return
        }
        
        /// Create http request
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        /// Send request
        URLSession.shared.downloadTask(with: request) { result, response, error in
            /// Complete with error if no data was downloaded or data was not saved
            guard let audioFileLocation = result else {
                completion(.failure(.custom(errorMessage: "No audio received")))
                return
            }
            /// Complete with success otherwise
            completion(.success(audioFileLocation))
        }.resume()
    }
}

