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
        let maxFrames = Int64(format.sampleRate * 25.0)
        let targetFrames = file.length < maxFrames ? file.length : maxFrames
        let frameCount = AVAudioFrameCount(targetFrames)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return defaultBPM }
        try? file.read(into: buffer)
        
        guard let floatData = buffer.floatChannelData?[0] else { return defaultBPM }
        
        let sampleRate = format.sampleRate
        let length = Int(buffer.frameLength)
        
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
        
        var peakCount = 0
        let threshold: Float = 0.04
        var lastPeakIndex = 0
        
        for k in 1..<(energyHistory.count - 1) {
            let prev = energyHistory[k - 1]
            let curr = energyHistory[k]
            let next = energyHistory[k + 1]
            
            if curr > prev && curr > next && curr > threshold {
                if k - lastPeakIndex > 12 {
                    peakCount += 1
                    lastPeakIndex = k
                }
            }
        }
        
        let duration = Double(length) / sampleRate
        let bps = Double(peakCount) / duration
        let bpm = bps * 60.0
        
        var finalBPM = bpm
        while finalBPM < 60 { finalBPM *= 2 }
        while finalBPM > 180 { finalBPM /= 2 }
        
        return finalBPM
    }
}

// MARK: - Smart Transition Coordinator (On-Beat Trigger & Constant-Power Crossfade)

class AIDJTransitionCoordinator {
    var primaryPlayer: AVAudioPlayer?
    var secondaryPlayer: AVAudioPlayer?
    
    var isTransitioning = false
    
    func startTransition(from playerA: AVAudioPlayer, toTrack url: URL, onPlayStarted: @escaping (AVAudioPlayer) -> Void, completion: @escaping (AVAudioPlayer) -> Void) {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        self.primaryPlayer = playerA
        
        // 1. Calculate the beat interval of the currently playing track to perform on-beat alignment
        let bpmA = BeatDetector.estimateBPM(for: playerA.url!)
        let beatInterval = 60.0 / bpmA
        
        print("[DJEngine] Starting transition: Song A (\(bpmA) BPM, Beat interval: \(beatInterval)s) -> Song B")
        
        // 2. Initialize Player B with bit-perfect native configuration (enableRate is false to avoid DSP quality degradation)
        guard let playerB = try? AVAudioPlayer(contentsOf: url) else {
            isTransitioning = false
            return
        }
        
        playerB.volume = 0.0
        playerB.prepareToPlay()
        self.secondaryPlayer = playerB
        
        // 3. Calculate time until the next beat in Song A to align the start of Song B
        let elapsedInBeat = playerA.currentTime.truncatingRemainder(dividingBy: beatInterval)
        let timeUntilNextBeat = beatInterval - elapsedInBeat
        
        // Trigger Song B exactly on-beat with Song A
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilNextBeat) { [weak self] in
            guard let self = self else { return }
            
            playerB.play()
            onPlayStarted(playerB)
            
            // 4. Perform Constant-Power (Sine/Cosine) Crossfade over 5.0 seconds
            let duration: TimeInterval = 5.0
            let steps = 50
            let interval = duration / Double(steps)
            var currentStep = 0
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                currentStep += 1
                let progress = Double(currentStep) / Double(steps)
                
                // Constant-power trigonometric curve: sum of squares is always 1.0 (no volume dips)
                let angle = progress * (.pi / 2.0)
                playerA.volume = Float(cos(angle))
                playerB.volume = Float(sin(angle))
                
                if currentStep >= steps {
                    timer.invalidate()
                    playerA.stop()
                    playerB.volume = 1.0
                    self.isTransitioning = false
                    completion(playerB)
                }
            }
        }
    }
}
