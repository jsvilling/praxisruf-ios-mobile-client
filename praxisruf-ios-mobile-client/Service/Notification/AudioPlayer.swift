//
//  AudioPlayer.swift
//  praxisruf-ios-mobile-client
//
//  Created by J. Villing on 02.11.21.
//

import Foundation
import AVFoundation

/// This class allows playing audio either based on a file locator or the id of a system sound.
class AudioPlayer : NSObject, AVAudioPlayerDelegate {

    private var player: AVAudioPlayer?
    
    private var queue: [URL] = []
    
    /// Plays the audio file at the given filePath.
    /// No audio will play, if the file does not exist.
    func playSounds(filePath: URL) {
        queue.append(filePath)
        playNextInQueue()
     }
    
    private func playNextInQueue() {
        if (!queue.isEmpty) {
            do {
                sleep(1)
                try self.player = AVAudioPlayer(contentsOf: queue.removeFirst())
                self.player?.delegate = self
                self.player?.play()
                sleep(2)
            } catch {
                print("Could not play audio")
            }
        }
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

extension AudioPlayer  {
    static let shared = AudioPlayer()
}
