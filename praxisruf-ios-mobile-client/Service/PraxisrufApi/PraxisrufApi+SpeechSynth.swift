//
//  PraxisrufApi+SpeechSynth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

extension PraxisrufApi {
    
    func synthesize(authToken: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        
        guard let audioUrl = URL(string: "\(baseUrlValue)/speechsynthesis") else {
            completion(.failure(.custom(errorMessage: "Invalid url configuration")))
            return
        }
        URLSession.shared.downloadTask(with: audioUrl) { result, response, error in
            guard let audioFileLocation = result else {
                completion(.failure(.custom(errorMessage: "No audio received")))
                return
            }
            completion(.success(audioFileLocation))
        }.resume()
    }
    
}
