//
//  SpeechSynthesisService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

class SpeechSynthesisService {
    
    func synthesize(_ notification: ReceiveNotification, _ errorHandler: @escaping (Error) -> Void) {
        let notificationType = notification.notificationType
        let version = notification.version
        let fileManager = FileManager.default
        let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationUrl = cacheUrl.appendingPathExtension("\(notificationType)-\(version)\(notification.senderId)")
        
        if (false && fileManager.fileExists(atPath: destinationUrl.path)) {
            playSpeechAudioFromCache(filePath: destinationUrl.path)
        } else {
            PraxisrufApi().synthesize(notificationType: notificationType, sender: notification.senderId) { result in
                switch result {
                    case .success(let audioUrl):
                        try? FileManager.default.removeItem(at: destinationUrl)
                        do {
                            try FileManager.default.copyItem(at: audioUrl, to: destinationUrl)
                            AudioPlayer.playSounds(filePath: destinationUrl.path)
                        } catch let error {
                            errorHandler(error)
                        }
                    case .failure(let error):
                        errorHandler(error)
                }
            }
        }
    }
    
    private func playSpeechAudioFromCache(filePath: String) {
        AudioPlayer.playSounds(filePath: filePath)
    }
}
