//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation
import SwiftKeychainWrapper

class PraxisrufApi {
    
    enum PraxisrufApiError: Error {
        case invalidCredential
        case invalidData
        case errorResponse
        case custom(errorMessage: String)
    }
        
    let baseUrlValue = "https://www.praxisruf.ch/api"
                
    private func authorizedRequest(_ subUrl: String, method: String = "GET", task: @escaping (URLRequest) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)\(subUrl)") else {
            fatalError("Invalid url configuration")
        }
                
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            fatalError("No authorization found")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        task(request)
    }
    
    func get<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        authorizedRequest(subUrl) { request in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.errorResponse))
                    return
                }
                
                guard let responsData = data else {
                    completion(.failure(.invalidData))
                     return
                 }
                
                guard let result = try? JSONDecoder().decode(T.self, from: responsData) else {
                    completion(.failure(.invalidData))
                    return
                }
            
                completion(.success(result))
            }.resume()
            
        }
    }
    
    func post<T>(_ subUrl: String, body: Data? = nil, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        authorizedRequest(subUrl, method: "POST") { r in
            var request = r
            
            if (body != nil) {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(.errorResponse))
                        return
                    }
                
                    guard let responsData = data else {
                        completion(.failure(.invalidData))
                         return
                     }
                
                    guard let result = try? JSONDecoder().decode(T.self, from: responsData) else {
                        completion(.failure(.invalidData))
                        return
                    }
                
                    completion(.success(result))
                
                
            }.resume()
        }
    }
    
    func delete(_ subUrl: String, completion: @escaping (Result<String, PraxisrufApiError>) -> Void) {
        authorizedRequest(subUrl) { request in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.errorResponse))
                    return
                }
                completion(.success("Success"))
            }.resume()
        }
    }
    
    func download(_ subUrl: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        authorizedRequest(subUrl) { request in
            
            URLSession.shared.downloadTask(with: request) { result, response, error in
                guard let audioFileLocation = result else {
                    completion(.failure(.custom(errorMessage: "No audio received")))
                    return
                }
                completion(.success(audioFileLocation))
            }.resume()
        }
    }
    
}
