//
//  AIDJEngine.swift
//  Krank
//

import UIKit
import AVFoundation

// MARK: - Local Beat Detector & BPM Estimator

class BeatDetector {
    static func estimateBPM(for url: URL) -> Double {
        let defaultBPM = 120.0
        
        guard let file = try? AVAudioFile(forReading: url) else { return defaultBPM }
        let format = file.processingFormat
        // Read the first 25 seconds of the song to calculate BPM quickly
        let maxFrames = Int64(format.sampleRate * 25.0)
        let targetFrames = file.length < maxFrames ? file.length : maxFrames
        let frameCount = AVAudioFrameCount(targetFrames)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return defaultBPM }
        try? file.read(into: buffer)
        
        guard let floatData = buffer.floatChannelData?[0] else { return defaultBPM }
        
        let sampleRate = format.sampleRate
        let length = Int(buffer.frameLength)
        
        // Compute audio energy in hops of 512 samples
        let hopSize = 512
        let winSize = 1024
        var energyHistory: [Float] = []
        
        var i = 0
        while i < length - winSize {
            var sum: Float = 0
            for j in 0..<hopSize {
                let sample = floatData[i + j]
                sum += sample * sample
            }
            energyHistory.append(sum)
            i += hopSize
        }
        
        // Count rhythmic peaks to estimate tempo
        var peakCount = 0
        let threshold: Float = 0.04
        var lastPeakIndex = 0
        
        for k in 1..<(energyHistory.count - 1) {
            let prev = energyHistory[k - 1]
            let curr = energyHistory[k]
            let next = energyHistory[k + 1]
            
            if curr > prev && curr > next && curr > threshold {
                if k - lastPeakIndex > 12 { // Debounce close peaks to avoid double triggering
                    peakCount += 1
                    lastPeakIndex = k
                }
            }
        }
        
        let duration = Double(length) / sampleRate
        let bps = Double(peakCount) / duration
        let bpm = bps * 60.0
        
        // Clamp computed tempo to common musical ranges: 60 - 180 BPM
        var finalBPM = bpm
        while finalBPM < 60 { finalBPM *= 2 }
        while finalBPM > 180 { finalBPM /= 2 }
        
        return finalBPM
    }
}

// MARK: - Smart Transition Coordinator (Beat-matching & Tempo Ramping)

class AIDJTransitionCoordinator {
    var primaryPlayer: AVAudioPlayer?
    var secondaryPlayer: AVAudioPlayer?
    
    var isTransitioning = false
    
    func startTransition(from playerA: AVAudioPlayer, toTrack url: URL, completion: @escaping (AVAudioPlayer) -> Void) {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        self.primaryPlayer = playerA
        
        // Run BPM estimation
        let bpmA = BeatDetector.estimateBPM(for: playerA.url!)
        let bpmB = BeatDetector.estimateBPM(for: url)
        
        print("[AIDJ] Starting smart transition: Song A (\(bpmA) BPM) -> Song B (\(bpmB) BPM)")
        
        // Initialize player B
        guard let playerB = try? AVAudioPlayer(contentsOf: url) else {
            isTransitioning = false
            return
        }
        
        playerB.enableRate = true
        playerB.volume = 0.0
        playerB.prepareToPlay()
        self.secondaryPlayer = playerB
        
        // Beat matching: Adjust Song B's rate to match Song A's tempo
        let matchedRate = Float(bpmA / bpmB)
        // Clamp rate variation to +/- 20% to avoid comical pitch shifts
        let targetRate = min(max(matchedRate, 0.8), 1.2)
        playerB.rate = targetRate
        
        // Start playback
        playerB.play()
        
        // Smooth crossfade + dynamic tempo ramp
        let duration: TimeInterval = 6.0 // 6 second transition
        let steps = 60
        let interval = duration / Double(steps)
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            let progress = Double(currentStep) / Double(steps)
            
            // Linear volume fade
            playerA.volume = Float(1.0 - progress)
            playerB.volume = Float(progress)
            
            if currentStep >= steps {
                timer.invalidate()
                playerA.stop()
                playerB.volume = 1.0
                playerB.rate = 1.0
                self.isTransitioning = false
                completion(playerB)
            }
        }
    }
}
