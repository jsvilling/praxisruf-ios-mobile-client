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
        let fileManager = FileManager.default
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationUrl = cacheUrl.appendingPathExtension("id1")
        
        if (fileManager.fileExists(atPath: destinationUrl.path)) {
            print("Speech Data is loadad from cache")
            AudioPlayer.playSounds(filePath: destinationUrl.path)
        } else {
            
            print("Speech Data is loadd from server")
        
        
        let defaults = UserDefaults.standard
        guard let authToken = defaults.string(forKey: UserDefaultKeys.authToken) else {
            print("No auth token found")
            return
        }
        PraxisrufApi().synthesize(authToken: authToken, notificationType: notificationType) { result in
            switch result {
                case .success(let audioUrl):
                
                    
                
                
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

    
}
