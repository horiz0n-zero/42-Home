//
//  HomeFX.swift
//  home42
//
//  Created by Antoine Feuerstein on 19/05/2021.
//

import Foundation
import UIKit
import AVKit

final class HomeFX: NSObject {
    
    @frozen enum SongEffect: String {
        case success = "success.mp3"
    }
    
    final private class OnceAudioPlayer: AVAudioPlayer, AVAudioPlayerDelegate {
        
        private var reference: OnceAudioPlayer!
        
        @discardableResult init(_ song: SongEffect) {
            try! super.init(contentsOf: HomeResources.applicationDirectory.appendingPathComponent("res/fx/\(song.rawValue)"))
            self.delegate = self
            self.reference = self
            self.prepareToPlay()
            self.play()
        }
        override init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
            try super.init(contentsOf: url, fileTypeHint: utiString)
        }
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            self.reference = nil
        }
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.reference = nil
        }
    }
    
    static func play(_ song: SongEffect) {
        OnceAudioPlayer(song)
    }
}
