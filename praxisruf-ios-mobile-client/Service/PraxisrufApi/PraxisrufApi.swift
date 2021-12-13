//
//  Api.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 18.10.21.
//

import Foundation
import SwiftKeychainWrapper

class PraxisrufApi {
    
    struct Nothing : Decodable {}
    
    enum PraxisrufApiError: Error {
        case invalidCredential
        case invalidData
        case errorResponse
        case custom(errorMessage: String)
    }
        
    let baseUrlValue = "https://www.praxisruf.ch/api"
                
    func get<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, completion: completion)
    }
    
    func post<T>(_ subUrl: String, body: Data? = nil, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, method: "POST", body: body, completion: completion)
    }
    
    func delete<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        http(subUrl, method: "DELETE", completion: completion)
    }
    
    private func http<T>(_ subUrl: String, method: String = "GET", body: Data? = nil, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        let url = URL(string: "\(baseUrlValue)\(subUrl)")!
                
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
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
    
    func download(_ subUrl: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        guard let url = URL(string: "\(baseUrlValue)\(subUrl)") else {
            completion(.failure(.invalidData))
            return
        }
                
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.downloadTask(with: request) { result, response, error in
            guard let audioFileLocation = result else {
                completion(.failure(.custom(errorMessage: "No audio received")))
                return
            }
            completion(.success(audioFileLocation))
        }.resume()
    }
    
    func websocket(_ subUrl: String) -> URLSessionWebSocketTask {
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            print("No authToken found")
            fatalError()
        }
        
        let url = URL(string: "ws://192.168.0.193:5000/name?clientId=123")!
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession(configuration: .default).webSocketTask(with: request)
        task.resume()
        
        return task
    }
    
}
