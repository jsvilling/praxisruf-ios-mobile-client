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

    /// Plays the audio file at the given filePath.
    /// No audio will play, if the file does not exist.
    static func playSounds(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
     }
    
    /// Plays the system sound with the given id.
    /// No audio will play, if no sound with the given id exists. 
    static func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}
