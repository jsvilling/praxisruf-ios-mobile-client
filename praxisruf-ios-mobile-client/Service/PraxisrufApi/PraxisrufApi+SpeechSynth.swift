//
//  PraxisrufApi+SpeechSynth.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

/// Extension of PraxisrufApi which enables synthesizing notification data via the speech synthesis api
extension PraxisrufApi {
    
    /// Makes a download call to the speech synthesis api with the given sender and notificationType ids.
    ///
    /// This is used by the SpeechSynthesisService. 
    func synthesize(notificationType: String, sender: String, completion: @escaping (Result<URL, PraxisrufApiError>) -> Void) {
        download("/speech/\(notificationType)?sender=\(sender)", completion: completion)
    }
}
