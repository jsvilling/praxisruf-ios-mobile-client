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
    
    public enum PraxisrufApiError: Error {
        case invalidCredential
        case invalidData
        case errorResponse
        case custom(errorMessage: String)
    }
        
    static let httpBaseUrlValue = "https://www.praxisruf.ch/api"
    static let webSocketBaseUrlValue = "wss://www.praxisruf.ch"
    
                
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
        let url = URL(string: "\(PraxisrufApi.httpBaseUrlValue)\(subUrl)")!
                
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
        guard let url = URL(string: "\(PraxisrufApi.httpBaseUrlValue)\(subUrl)") else {
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
        
        let url = URL(string: "\(PraxisrufApi.webSocketBaseUrlValue)\(subUrl)")!
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession(configuration: .default).webSocketTask(with: request)
        task.resume()
        
        return task
    }
    
    func authorizedWebSocket(_ subUrl: String, completion: @escaping (Result<URLSessionWebSocketTask, PraxisrufApiError>) -> Void) {
        let url = URL(string: "\(PraxisrufApi.webSocketBaseUrlValue)\(subUrl)")!
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession(configuration: .default).webSocketTask(with: request)
        completion(.success(task))
    }
    
    func websocket<T>(_ subUrl: String, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) -> URLSessionWebSocketTask? where T : Decodable {
        let url = URL(string: "\(PraxisrufApi.webSocketBaseUrlValue)\(subUrl)")!
        guard let authToken = KeychainWrapper.standard.string(forKey: UserDefaultKeys.authToken) else {
            completion(.failure(.invalidCredential))
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession(configuration: .default).webSocketTask(with: request)
        task.resume()
        task.receive() { message in
            switch(message) {
                case .success(let content):
                    self.processWebsocketSuccessResponse(content: content, completion: completion)
                case .failure(let error):
                    completion(.failure(PraxisrufApiError.custom(errorMessage: error.localizedDescription)))
            }
        }
        return task
    }
    
    private func processWebsocketSuccessResponse<T>(content: URLSessionWebSocketTask.Message, completion: @escaping (Result<T, PraxisrufApiError>) -> Void) where T : Decodable {
        switch(content) {
            case .string(let string):
            guard let result = try? JSONDecoder().decode(T.self, from: string.data(using: .utf8)!) else {
                    completion(.failure(.invalidData))
                    return
                }
                completion(.success(result))
            default:
                completion(.failure(.invalidData))
        }
    }
    
}

