//
//  AudioPlayer.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFoundation

class AudioPlayer {

    static func playSounds(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
     }
}
