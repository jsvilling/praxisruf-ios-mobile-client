//
//  SpeechSynthesisService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

class SpeechSynthesisService {
    
    func synthesize() {
        let defaults = UserDefaults.standard
        guard let authToken = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No auth token found")
            return
        }
        PraxisrufApi().synthesize(authToken: authToken) { result in
            switch result {
                case .success(let audioUrl):
                    AudioPlayer.playSounds(filePath: audioUrl.path)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }

    
}
