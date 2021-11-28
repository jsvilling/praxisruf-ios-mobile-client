//
//  PraxisrufApi+SpeechSynth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

extension PraxisrufApi {
    
    func synthesize(authToken: String, notificationType: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        guard let audioUrl = URL(string: "\(baseUrlValue)/speech/\(notificationType)") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }
        
        var request = URLRequest(url: audioUrl)
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.downloadTask(with: request) { result, response, error in
            guard let audioFileLocation = result else {
                completion(.failure(.custom(errorMessage: "No audio received")))
                return
            }
            completion(.success(audioFileLocation))
        }.resume()
    }
    
}
