//
//  PlayerManager.swift
//  DontecoTest
//
//  Created by Дмитрий Болучевских on 18.04.2022.
//

import AVFoundation
import MediaPlayer

final class PlayerManager {
    static let shared = PlayerManager()
    
    @Published var playingCopy: Bool = false
    
    private let playerQueue = [AVPlayer(), AVPlayer()]
    private var timeObserverToken: Any?
    
    private var crossFadeDuration: Double = 2.0
    
    private var currentPlayer: AVPlayer {
        return self.playingCopy ? self.playerQueue.last! : self.playerQueue.first!
    }
    
    func setupFade(for tracks: [MPMediaItem], withFadeDuration: Double) {
        if let firstUrl = tracks.first?.assetURL,
           let secondUrl = tracks.last?.assetURL {
            currentPlayer.replaceCurrentItem(with: AVPlayerItem(url: firstUrl))
            playerQueue.last?.replaceCurrentItem(with: AVPlayerItem(url: secondUrl))
        }
        
        crossFadeDuration = withFadeDuration
        addVolumeRamps(with: withFadeDuration)
        addPeriodicTimeObserver(for: currentPlayer)
    }
    
    func playPauseMusic(_ isNowPlaying: Bool) {
        if isNowPlaying {
            currentPlayer.pause()
        } else {
            currentPlayer.play()
        }
    }
    
    private func addVolumeRamps(with duration: Double) {
        for player in playerQueue {
            let assetDuration = CMTimeGetSeconds(player.currentItem!.asset.duration)
            
            let introRange = CMTimeRangeMake(start: CMTimeMakeWithSeconds(0, preferredTimescale: 1), duration: CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
            let endingSecond = CMTimeRangeMake(start: CMTimeMakeWithSeconds(assetDuration - duration, preferredTimescale: 1), duration: CMTimeMakeWithSeconds(duration, preferredTimescale: 1))
            
            let inputParams = AVMutableAudioMixInputParameters(track: player.currentItem?.asset.tracks.first)
            inputParams.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1, timeRange: introRange)
            inputParams.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: endingSecond)
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [inputParams]
            player.currentItem?.audioMix = audioMix
        }
    }
    
    private func addPeriodicTimeObserver(for player: AVPlayer) {
        timeObserverToken = currentPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] currentTime in
            if let currentItem = self?.currentPlayer.currentItem,
               currentItem.status == .readyToPlay,
               let crossFadeDuration = self?.crossFadeDuration {
                let totalDuration = currentItem.asset.duration
                
                if (CMTimeCompare(currentTime, totalDuration - CMTimeMakeWithSeconds(crossFadeDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) > 0) {
                    self?.handleCrossFade()
                }
            }
        }
    }
    
    private func removePeriodicTimeObserver(for player: AVPlayer) {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func handleCrossFade() {
        removePeriodicTimeObserver(for: currentPlayer)
        playingCopy = !playingCopy
        addPeriodicTimeObserver(for: currentPlayer)
        
        currentPlayer.seek(to: .zero)
        currentPlayer.play()
    }
}
