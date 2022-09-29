// home42/HomeFX.swift
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ *
+
+      :::       ::::::::
+     :+:       :+:    :+:
+    +:+   +:+        +:+
+   +#+   +:+       +#+
+  +#+#+#+#+#+    +#+
+       #+#     #+#
+      ###    ######## H O M E
+
+   Copyright Antoine Feuerstein. All rights reserved.
+
* ++++++++++++++++++++++++++++++++++++++++++++++++++++ */

import Foundation
import UIKit
import AVKit

final class HomeFX: NSObject {
    
    @frozen enum SongEffect: String {
        case success = "success.mp3"
        case clickButton01 = "click_button_01.wav"
        case clickButton06 = "click_button_06.wav"
    }
    
    final private class OnceAudioPlayer: AVAudioPlayer, AVAudioPlayerDelegate {
        
        private var reference: OnceAudioPlayer!
        
        @discardableResult init(_ song: SongEffect) {
            try! super.init(contentsOf: HomeResources.applicationDirectory.appendingPathComponent("res/fx/\(song.rawValue)"))
            self.delegate = self
            self.reference = self
            self.prepareToPlay()
            self.play()
            self.volume = 100.0
            #if DEBUG
            print("Fx", song.rawValue)
            #endif
        }
        override init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
            try super.init(contentsOf: url, fileTypeHint: utiString)
        }
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            #if DEBUG
            print(#function, error ?? "nil")
            #endif
            self.reference = nil
        }
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.reference = nil
        }
    }
    
    static private var haptic: UIImpactFeedbackGenerator = {
        let haptic =  UIImpactFeedbackGenerator.init(style: .light)
        
        return haptic
    }()
    
    static func play(_ song: SongEffect) {
        OnceAudioPlayer(song)
        HomeFX.haptic.prepare()
        HomeFX.haptic.impactOccurred()
    }
}
