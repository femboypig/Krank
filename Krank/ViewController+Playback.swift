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
            
            // Scroll to full player page
            let width = scrollView.frame.size.width
            scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: true)
            
        } catch {
            print("Audio Player playback error: \(error)")
            showToast(message: "Playback failed", success: false)
        }
    }
    
    func playOrPause() {
        guard audioPlayer != nil else {
            if !filteredTracks.isEmpty {
                currentTrackIndex = 0
                playCurrentTrack()
            }
            return
        }
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
            stopArtworkAnimation()
        } else {
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
            startArtworkAnimation()
            
            let playbackImpact = UIImpactFeedbackGenerator(style: .medium)
            playbackImpact.prepare()
            playbackImpact.impactOccurred()
        }
        updateNowPlayingInfo()
        updateMiniPlayerUI()
    }
    
    func rebuildShuffleQueue() {
        guard !filteredTracks.isEmpty else {
            shuffledIndices = []
            shuffledPosition = 0
            return
        }
        
        let count = filteredTracks.count
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
    
    @objc func playPreviousTrack() {
        guard !filteredTracks.isEmpty else { return }
        
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
