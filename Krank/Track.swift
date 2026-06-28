//
//  Track.swift
//  Krank
//

import UIKit
import AVFoundation

struct Track {
    let url: URL
    var title: String
    var artist: String
    var duration: TimeInterval
    var artwork: UIImage?
    
    @available(iOS, deprecated: 16.0)
    init(url: URL) {
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.artist = "Unknown Artist"
        self.duration = 0
        
        let asset = AVAsset(url: url)
        
        // Duration extraction
        self.duration = CMTimeGetSeconds(asset.duration)
        if self.duration.isNaN || self.duration.isInfinite {
            self.duration = 0
        }
        
        // Metadata extraction
        let metadata = asset.commonMetadata
        for item in metadata {
            guard let key = item.commonKey else { continue }
            switch key {
            case .commonKeyTitle:
                if let titleVal = item.stringValue {
                    self.title = titleVal
                }
            case .commonKeyArtist:
                if let artistVal = item.stringValue {
                    self.artist = artistVal
                }
            case .commonKeyArtwork:
                if let data = item.dataValue {
                    self.artwork = UIImage(data: data)
                }
            default:
                break
            }
        }
    }
}
