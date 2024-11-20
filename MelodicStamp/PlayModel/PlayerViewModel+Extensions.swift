//
//  PlayerViewModel+Extensions.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import Foundation
import MediaPlayer

extension PlayerViewModel {
    
    func updateNowPlayingState(_ state: MPNowPlayingPlaybackState) {
        nowPlayingInfoCenter.playbackState = state
    }
    
    func setupRemoteCommandCenter() {
        print("setupRemoteCommandCenter")
        let rcCenter = remoteCommandCenter
        
        rcCenter.playCommand.addTarget { _ in
            do {
                try self.player.play()
                return .success
            } catch {
                self.handleError(error) // 处理错误，例如记录日志或显示通知
                return .commandFailed
            }
        }
        
        rcCenter.pauseCommand.addTarget { _ in
            self.player.pause()
            return .success
        }
        
        rcCenter.togglePlayPauseCommand.addTarget { _ in
            do {
                try self.togglePlayPause()
                return .success
            } catch {
                self.handleError(error)
                return .commandFailed
            }
        }
        
        rcCenter.stopCommand.addTarget { _ in
            //self.stop()
            return .success
        }
        
        rcCenter.nextTrackCommand.addTarget { _ in
            self.nextTrack()
            return .success
        }
        
        rcCenter.previousTrackCommand.addTarget { _ in
            self.previousTrack()
            return .success
        }
        
        rcCenter.changeRepeatModeCommand.addTarget { _ in
            // Uncomment and implement if needed
            // self.toggleRepeatMode()
            return .success
        }
        
        rcCenter.changeShuffleModeCommand.isEnabled = false
        
        
        rcCenter.changeShuffleModeCommand.addTarget { _ in
            // Uncomment and implement if needed
            // self.toggleShuffleMode()
            return .success
        }
        
        rcCenter.changePlaybackRateCommand.isEnabled = true
        
        rcCenter.seekForwardCommand.isEnabled = true
        
        rcCenter.seekBackwardCommand.isEnabled = true
        
        rcCenter.changePlaybackPositionCommand.addTarget { event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let positionTime = positionEvent.positionTime // This is already a Double (seconds).
            self.seek(position: positionTime) // Adjust the method name and parameters as required by your seek method.
            self.updateNowPlayingInfo()
            return .success
        }
    }
    
    func initNowPlayingInfo() {
        
        guard let track = nowPlaying, let appIcon = NSApp.applicationIconImage else {
//            nowPlayingInfoCenter.nowPlayingInfo = nil
//            updateNowPlayingState(.unknown)
            return
        }
        
        var info = [String: Any]()
        
        info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        info[MPMediaItemPropertyTitle] = track.metadata.title
        info[MPMediaItemPropertyArtist] = track.metadata.artist
        info[MPMediaItemPropertyAlbumTitle] = track.metadata.albumTitle
        info[MPMediaItemPropertyAlbumArtist] = track.metadata.albumArtist
        info[MPMediaItemPropertyArtwork] = track.metadata.attachedPictures.first?.image
        
        nowPlayingInfoCenter.nowPlayingInfo = nil
        nowPlayingInfoCenter.nowPlayingInfo = info
    }
    
    func updateNowPlayingInfo() {
        guard let track = nowPlaying, nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String == track.metadata.title else {
            return
        }
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyPlaybackDuration] = remaining / 1000
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        
        // info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1
        nowPlayingInfoCenter.nowPlayingInfo = info
    }
}
