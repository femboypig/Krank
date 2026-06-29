//
//  ViewController+Playback.swift
//  Krank
//

import UIKit
import AVFoundation
import MediaPlayer

extension ViewController {

    // MARK: - Core Audio Setup
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure Audio Session: \(error)")
        }
    }
    
    func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviousTrack()
            return .success
        }
    }
    
    // MARK: - Playback Core Engine
    
    func playCurrentTrack() {
        guard !filteredTracks.isEmpty, let index = currentTrackIndex, index < filteredTracks.count else { return }
        
        let track = filteredTracks[index]
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: track.url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            let playbackImpact = UIImpactFeedbackGenerator(style: .medium)
            playbackImpact.prepare()
            playbackImpact.impactOccurred()
            
            startTimer()
            
            // Full UI updating
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
            trackTitleLabel.text = track.title
            
            // Artist label handling (hiding if empty or unknown)
            if track.artist != "Unknown Artist" && !track.artist.isEmpty {
                artistLabel.text = track.artist
                artistLabel.isHidden = false
            } else {
                artistLabel.text = ""
                artistLabel.isHidden = true
            }
            
            if let artwork = track.artwork {
                coverImageView.image = artwork
            } else {
                coverImageView.image = UIImage(named: "logo")
            }
            
            progressSlider.maximumValue = Float(track.duration)
            progressSlider.value = 0
            
            startArtworkAnimation()
            updateNowPlayingInfo()
            tableView.reloadData()
            
            updateMiniPlayerUI()
            updatePlayerFavoriteButton()
            
            // Scroll to full player page ONLY if we are not already on the player page
            let width = scrollView.frame.size.width
            let currentPage = Int(round(scrollView.contentOffset.x / width))
            if currentPage != 2 {
                scrollView.setContentOffset(CGPoint(x: width * 2, y: 0), animated: true)
            }
            
        } catch {
            print("Audio Player playback error: \(error)")
            showToast(message: "Playback failed", success: false)
        }
    }
    
    func playOrPause() {
        guard let player = audioPlayer else {
            if !filteredTracks.isEmpty {
                currentTrackIndex = 0
                playCurrentTrack()
            }
            return
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
        
        if aidj.isTransitioning {
            aidj.primaryPlayer?.stop()
            aidj.isTransitioning = false
        }
        
        if player.isPlaying {
            player.pause()
            updateTimer?.invalidate()
            stopArtworkAnimation()
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
        } else {
            player.play()
            startTimer()
            startArtworkAnimation()
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
        }
        
        updateNowPlayingInfo()
        updateMiniPlayerUI()
    }
    
    // MARK: - Playback Queue Navigation
    
    func rebuildShuffleQueue() {
        let count = filteredTracks.count
        guard count > 0 else { return }
        
        var indices = Array(0..<count)
        if let currentIdx = currentTrackIndex, currentIdx < count {
            indices.remove(at: currentIdx)
            indices.shuffle()
            shuffledIndices = [currentIdx] + indices
            shuffledPosition = 0
        } else {
            indices.shuffle()
            shuffledIndices = indices
            shuffledPosition = 0
        }
    }
    
    @objc func playNextTrack() {
        guard !filteredTracks.isEmpty else { return }
        
        if aidj.isTransitioning {
            aidj.primaryPlayer?.stop()
            aidj.isTransitioning = false
        }
        
        forcePlayNextTrack()
    }
    
    func forcePlayNextTrack() {
        if isShuffleEnabled {
            if shuffledIndices.isEmpty {
                rebuildShuffleQueue()
            }
            
            if shuffledPosition >= shuffledIndices.count - 1 {
                if isRepeatEnabled {
                    rebuildShuffleQueue()
                } else {
                    shuffledPosition = 0
                }
            } else {
                shuffledPosition += 1
            }
            
            if shuffledPosition < shuffledIndices.count {
                currentTrackIndex = shuffledIndices[shuffledPosition]
                playCurrentTrack()
            }
        } else {
            if let index = currentTrackIndex {
                currentTrackIndex = (index + 1) % filteredTracks.count
            } else {
                currentTrackIndex = 0
            }
            playCurrentTrack()
        }
    }
    
    func transitionToNextTrack() {
        guard !filteredTracks.isEmpty, let currentPlayer = audioPlayer else {
            forcePlayNextTrack()
            return
        }
        
        currentPlayer.delegate = nil // Stop delegating so old player stops quietly
        
        // Find next track index
        let nextIndex: Int
        if isShuffleEnabled {
            if shuffledIndices.isEmpty {
                rebuildShuffleQueue()
            }
            var nextPos = shuffledPosition
            if nextPos >= shuffledIndices.count - 1 {
                nextPos = 0
            } else {
                nextPos += 1
            }
            nextIndex = shuffledIndices[nextPos]
        } else {
            if let index = currentTrackIndex {
                nextIndex = (index + 1) % filteredTracks.count
            } else {
                nextIndex = 0
            }
        }
        
        let nextTrack = filteredTracks[nextIndex]
        
        // Start transition background tasks (tempo mapping & volume ramping)
        aidj.startTransition(from: currentPlayer, toTrack: nextTrack.url, onPlayStarted: { [weak self] _ in
            guard let self = self else { return }
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
            self.updateMiniPlayerUI()
        }, completion: { _ in
            // Done transitioning
        })
        
        // Immediately swap active reference to new player B, so timer & UI update instantly!
        if let playerB = aidj.secondaryPlayer {
            self.audioPlayer = playerB
            self.audioPlayer?.delegate = self
            self.currentTrackIndex = nextIndex
            
            if self.isShuffleEnabled {
                if self.shuffledPosition >= self.shuffledIndices.count - 1 {
                    self.shuffledPosition = 0
                } else {
                    self.shuffledPosition += 1
                }
            }
            
            // Full UI updating
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
            self.trackTitleLabel.text = nextTrack.title
            
            if nextTrack.artist != "Unknown Artist" && !nextTrack.artist.isEmpty {
                self.artistLabel.text = nextTrack.artist
                self.artistLabel.isHidden = false
            } else {
                self.artistLabel.text = ""
                self.artistLabel.isHidden = true
            }
            
            if let artwork = nextTrack.artwork {
                self.coverImageView.image = artwork
            } else {
                self.coverImageView.image = UIImage(named: "logo")
            }
            
            self.progressSlider.maximumValue = Float(nextTrack.duration)
            self.progressSlider.value = 0
            
            self.startArtworkAnimation()
            self.updateNowPlayingInfo()
            self.tableView.reloadData()
            
            self.updateMiniPlayerUI()
            self.updatePlayerFavoriteButton()
        }
    }
    
    @objc func playPreviousTrack() {
        guard !filteredTracks.isEmpty else { return }
        
        if aidj.isTransitioning {
            aidj.primaryPlayer?.stop()
            aidj.isTransitioning = false
        }
        
        if isShuffleEnabled {
            if shuffledIndices.isEmpty {
                rebuildShuffleQueue()
            }
            
            if shuffledPosition > 0 {
                shuffledPosition -= 1
            } else {
                shuffledPosition = shuffledIndices.count - 1
            }
            
            if shuffledPosition < shuffledIndices.count {
                currentTrackIndex = shuffledIndices[shuffledPosition]
                playCurrentTrack()
            }
        } else {
            if let index = currentTrackIndex {
                currentTrackIndex = (index - 1 + filteredTracks.count) % filteredTracks.count
            } else {
                currentTrackIndex = 0
            }
            playCurrentTrack()
        }
    }
    
    // MARK: - Playback Timer & Actions
    
    func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }
    
    func updatePlaybackProgress() {
        guard let player = audioPlayer, player.duration > 0 else { return }
        
        if !progressSlider.isTracking {
            progressSlider.value = Float(player.currentTime)
        }
        
        elapsedLabel.text = formatTime(player.currentTime)
        remainingLabel.text = "-" + formatTime(player.duration - player.currentTime)
        
        updateNowPlayingInfoElapsedTimeOnly()
        
        // Smart DJ Transition trigger: 6 seconds before natural completion
        let aidjEnabled = UserDefaults.standard.bool(forKey: "Krank_AIDJEnabled")
        if aidjEnabled && !isRepeatEnabled && player.duration - player.currentTime <= 6.0 && player.duration > 12.0 && !aidj.isTransitioning {
            transitionToNextTrack()
        }
    }
    
    @objc func sliderValueChanging(_ sender: UISlider) {
        elapsedLabel.text = formatTime(TimeInterval(sender.value))
        if let player = audioPlayer {
            remainingLabel.text = "-" + formatTime(player.duration - TimeInterval(sender.value))
        }
    }
    
    @objc func sliderFinishedChanging(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateNowPlayingInfo()
    }
    
    @objc func playPauseTapped() {
        playOrPause()
    }
    
    @objc func shuffleTapped() {
        isShuffleEnabled.toggle()
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @objc func repeatTapped() {
        isRepeatEnabled.toggle()
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @objc func volumeSliderChanged(_ sender: UISlider) {
        audioPlayer?.volume = sender.value
    }
    
    func updatePlaybackButtons() {
        let activeColor = UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0)
        let inactiveColor = secondaryTextColor()
        shuffleButton.tintColor = isShuffleEnabled ? activeColor : inactiveColor
        repeatButton.tintColor = isRepeatEnabled ? activeColor : inactiveColor
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isRepeatEnabled {
            playCurrentTrack()
        } else {
            playNextTrack()
        }
    }
}
