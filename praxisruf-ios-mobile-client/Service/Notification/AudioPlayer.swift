//
//  AudioPlayer.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFoundation

/// This class allows playing audio either based on a file locator or the id of a system sound.
class AudioPlayer {

    private var player: AVAudioPlayer?
    
    /// Plays the audio file at the given filePath.
    /// No audio will play, if the file does not exist.
    static func playSounds(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
     }
    
    func playAppSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Could not play audio for \(name)")
            return
        }
        do {
            try self.player = AVAudioPlayer(contentsOf: url)
            self.player?.play()
        } catch {
            print("Could not play audio for \(name)")
        }
    }
        
}
