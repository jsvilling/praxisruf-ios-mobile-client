//
//  PraxisrufApi+SpeechSynth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

extension PraxisrufApi {
    
    func synthesize(notificationType: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        get("/speech/\(notificationType)") { request in
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
