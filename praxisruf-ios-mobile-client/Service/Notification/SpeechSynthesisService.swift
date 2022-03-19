//
//  SpeechSynthesisService.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFAudio

/// This service implements speech synthesis in the application.
/// SpeechSyntesis data can be retrieved either from the praxisruf speech synthesis api or from a local cache.
class SpeechSynthesisService {
    
    /// Synthesises speech data for the given notification and plays the audio for it.
    ///
    /// When receiving a notification it is checked, whether the speech data is already known.
    /// This is done by looking for a file in the format of ''notificationTypeId-version-senderId''.
    /// If such a file is present, its data is played and processing ends.
    ///
    /// If no such file is present a request is made to the speech synthesis api of the cloudservice.
    /// This request returns the desired speech data.
    /// The received data is sotred in a file with name ''notificationTypeId-version-senderId'' and then played.
    ///
    /// This is called by the NotificationSerivce upon receiving a notification.
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
    
    /// Delegates the playing of an audio file to AudioPlayer. 
    private func playSpeechAudioFromCache(filePath: String) {
        AudioPlayer.playSounds(filePath: filePath)
    }
}
