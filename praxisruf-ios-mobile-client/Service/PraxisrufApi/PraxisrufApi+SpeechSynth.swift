//
//  PraxisrufApi+SpeechSynth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

extension PraxisrufApi {
    
    func synthesize(notificationType: String, sender: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        download("/speech/\(notificationType)?sender=\(sender)", completion: completion)
    }
}
