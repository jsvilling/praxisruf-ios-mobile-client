//
//  SpeechSynthesisService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

class SpeechSynthesisService {
    
    func synthesize(notificationType: String, version: String) {
        let defaults = UserDefaults.standard
        guard let authToken = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No auth token found")
            return
        }
        PraxisrufApi().synthesize(authToken: authToken) { result in
            switch result {
                case .success(let audioUrl):
                
                    
                let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let destinationUrl = cacheUrl.appendingPathExtension("id0")
                try? FileManager.default.removeItem(at: destinationUrl)
                
                do {
                    try FileManager.default.copyItem(at: audioUrl, to: destinationUrl)
                    AudioPlayer.playSounds(filePath: destinationUrl.path)
                } catch let error {
                    print(error)
                }
                
                
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }

    
}
