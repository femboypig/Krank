//
//  ViewController+Gestures.swift
//  Krank
//

import UIKit
import MediaPlayer

extension ViewController {

    // MARK: - Gestures & Category Swipe Actions
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let categories: [FilterCategory] = [.all, .favorites] + playlists.keys.sorted().map { .playlist($0) }
        guard let currentIndex = categories.firstIndex(of: activeFilter) else { return }
        
        if gesture.direction == .left {
            let nextIndex = currentIndex + 1
            if nextIndex < categories.count {
                activeFilter = categories[nextIndex]
                filterTracks()
                rebuildFiltersRow()
                
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.prepare()
                feedback.impactOccurred()
                
                animateTableFilter(direction: .left)
            }
        } else if gesture.direction == .right {
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                activeFilter = categories[prevIndex]
                filterTracks()
                rebuildFiltersRow()
                
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.prepare()
                feedback.impactOccurred()
                
                animateTableFilter(direction: .right)
            }
        }
    }
    
    // MARK: - Transition Animations
    
    func animateTableFilter(direction: UISwipeGestureRecognizer.Direction) {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = (direction == .left) ? .fromRight : .fromLeft
        transition.duration = 0.22
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        tableView.layer.add(transition, forKey: kCATransition)
    }
    
    // MARK: - Keyboard Handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if let bottomConstraint = activeSheetBottomConstraint {
            bottomConstraint.constant = -keyboardHeight - 16
            
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let bottomConstraint = activeSheetBottomConstraint {
            bottomConstraint.constant = -16
            
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === tableView {
            scrollFeedbackGenerator.prepare()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only apply the cylinder effect when the tableView itself is scrolling,
        // not the outer paging scrollView
        guard scrollView === tableView else { return }
        applyCylinderEffect()
        updateOverlayAlphas()
    }
    
    // MARK: - Cylinder / Drum-Roll Effect
    
    func updateOverlayAlphas() {
        guard let top = page1?.viewWithTag(7701),
              let bot = page1?.viewWithTag(7702) else { return }
        
        let offsetY = tableView.contentOffset.y
        let fadeLimit: CGFloat = 36.0
        
        // 1. Top overlay alpha transitions from 0.0 at rest to 1.0 after scrolling down 36pt
        if offsetY <= 0 {
            top.alpha = 0.0
        } else if offsetY < fadeLimit {
            top.alpha = offsetY / fadeLimit
        } else {
            top.alpha = 1.0
        }
        
        // 2. Bottom overlay alpha transitions from 0.0 at rest to 1.0 after scrolling up 36pt
        let tableHeight = tableView.bounds.height
        let contentHeight = tableView.contentSize.height
        let maxScrollY = contentHeight - tableHeight
        
        if maxScrollY <= 0 {
            bot.alpha = 0.0
        } else {
            let distFromBottom = maxScrollY - offsetY
            if distFromBottom <= 0 {
                bot.alpha = 0.0
            } else if distFromBottom < fadeLimit {
                bot.alpha = distFromBottom / fadeLimit
            } else {
                bot.alpha = 1.0
            }
        }
    }
    
    func applyCylinderEffect() {
        let tableHeight = tableView.bounds.height
        guard tableHeight > 0 else { return }
        
        // Half-height is the "equator" of the drum
        let centerY = tableView.contentOffset.y + tableHeight / 2
        
        // Mathematical offset-based haptic triggering (works for any number of tracks and sizes)
        let rowHeight: CGFloat = 56.0
        let currentOffset = tableView.contentOffset.y
        let roundedRow = Int(round(currentOffset / rowHeight))
        let maxRow = filteredTracks.count - 1
        
        if roundedRow >= 0 && roundedRow <= maxRow {
            if lastCenterRow != roundedRow {
                lastCenterRow = roundedRow
                // Instantly trigger light impact feedback
                scrollFeedbackGenerator.impactOccurred()
            }
        }
        
        // Calculate transition scales for top and bottom of the table
        // As currentOffset approaches 0, topEffectScale decreases to 0 (making cells flat/opaque)
        // 56pt (one row height) is the range over which the effect fades in/out.
        let transitionLimit: CGFloat = 56.0
        let topEffectScale = min(max(currentOffset / transitionLimit, 0.0), 1.0)
        
        let maxScrollY = tableView.contentSize.height - tableHeight
        let bottomEffectScale: CGFloat
        if maxScrollY <= 0 {
            bottomEffectScale = 0.0
        } else {
            let distFromBottom = maxScrollY - currentOffset
            bottomEffectScale = min(max(distFromBottom / transitionLimit, 0.0), 1.0)
        }
        
        for cell in tableView.visibleCells {
            let cellMidY = cell.frame.midY
            
            // Normalized distance from center: 0 = center, 1 = edge
            let rawDist = abs(cellMidY - centerY) / (tableHeight / 2)
            let dist = min(rawDist, 1.0)
            
            // Choose the scaling factor based on whether the cell is above or below the equator
            let cellScale = cellMidY < centerY ? topEffectScale : bottomEffectScale
            
            // Scale the distance (tilt & fade) by the cellScale
            let effectiveDist = dist * cellScale
            
            // Alpha: full opacity (1.0) in center, fades to 0.3 at the very edge (scaled by effectiveDist)
            let alpha = 1.0 - effectiveDist * 0.7
            
            // Scale: 1.0 at center, shrinks slightly at edges (scaled by effectiveDist)
            let scale = 1.0 - effectiveDist * 0.06
            
            // Subtle 3D tilt: rows "roll away" on the cylinder surface (scaled by effectiveDist)
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 600   // perspective
            let angle = effectiveDist * .pi * 0.18  // max ~32° rotation
            let direction: CGFloat = cellMidY < centerY ? -1 : 1
            transform = CATransform3DRotate(transform, angle * direction, 1, 0, 0)
            transform = CATransform3DScale(transform, scale, scale, 1)
            
            // Apply to contentView so UITableView's internal layouts don't override it
            cell.contentView.layer.transform = transform
            cell.contentView.alpha = alpha
        }
    }
    
    // MARK: - Artwork Animations
    
    func startArtworkAnimation() {
        coverArtCard.layer.removeAllAnimations()
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.duration = 4.0
        scale.fromValue = 1.0
        scale.toValue = 1.04
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scale.autoreverses = true
        scale.repeatCount = .infinity
        
        let glow = CABasicAnimation(keyPath: "shadowOpacity")
        glow.duration = 4.0
        glow.fromValue = 0.08
        glow.toValue = 0.22
        glow.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glow.autoreverses = true
        glow.repeatCount = .infinity
        
        coverArtCard.layer.add(scale, forKey: "artworkScale")
        coverArtCard.layer.add(glow, forKey: "artworkGlow")
    }
    
    func stopArtworkAnimation() {
        coverArtCard.layer.removeAllAnimations()
    }
    
    // MARK: - Toast Notifications
    
    func showToast(message: String, success: Bool) {
        if let existing = view.viewWithTag(999) {
            existing.removeFromSuperview()
        }
        
        let toast = UIView()
        toast.tag = 999
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.layer.cornerRadius = 20
        
        if success {
            toast.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(red: 0.18, green: 0.28, blue: 0.22, alpha: 0.95) : UIColor(red: 0.22, green: 0.35, blue: 0.28, alpha: 0.95)
            }
        } else {
            toast.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(red: 0.55, green: 0.18, blue: 0.12, alpha: 0.95) : UIColor(red: 0.65, green: 0.23, blue: 0.17, alpha: 0.95)
            }
        }
        
        view.addSubview(toast)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont(name: "Georgia-BoldItalic", size: 14)
        label.text = message
        label.textAlignment = .center
        toast.addSubview(label)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.heightAnchor.constraint(equalToConstant: 40),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: toast.centerYAnchor)
        ])
        
        toast.alpha = 0.0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            toast.alpha = 1.0;
            toast.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 2.0, options: [], animations: {
                toast.alpha = 0.0
                toast.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        if time.isNaN || time.isInfinite { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Lockscreen Sync
    
    func updateNowPlayingInfo() {
        guard let index = currentTrackIndex, index < filteredTracks.count else { return }
        let track = filteredTracks[index]
        
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = track.title
        info[MPMediaItemPropertyArtist] = track.artist
        info[MPMediaItemPropertyPlaybackDuration] = track.duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime ?? 0
        info[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer?.isPlaying == true ? 1.0 : 0.0
        
        if let artwork = track.artwork {
            let squaredArtwork = artwork.squared()
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: squaredArtwork.size, requestHandler: { _ in squaredArtwork })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    func updateNowPlayingInfoElapsedTimeOnly() {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    // MARK: - Persistence state
    
    func savePlaybackState() {
        if let index = currentTrackIndex, index < filteredTracks.count {
            UserDefaults.standard.set(filteredTracks[index].url.lastPathComponent, forKey: "Krank_LastTrackFile")
        }
    }
    
    func loadPlaybackState() {
        isShuffleEnabled = UserDefaults.standard.bool(forKey: "Krank_Shuffle")
        isRepeatEnabled = UserDefaults.standard.bool(forKey: "Krank_Repeat")
        
        if let lastFile = UserDefaults.standard.string(forKey: "Krank_LastTrackFile") {
            if let index = filteredTracks.firstIndex(where: { $0.url.lastPathComponent == lastFile }) {
                currentTrackIndex = index
                let track = filteredTracks[index]
                
                trackTitleLabel.text = track.title
                
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
            }
        }
        updatePlaybackButtons()
        updateMiniPlayerUI()
        updatePlayerFavoriteButton()
    }
}

// MARK: - UIImage Extension for Now Playing Symmetrical Artwork

fileprivate extension UIImage {
    func squared() -> UIImage {
        let originalWidth = self.size.width * self.scale
        let originalHeight = self.size.height * self.scale
        
        // If already square (or close to it), return directly
        if abs(originalWidth - originalHeight) < 1.0 {
            return self
        }
        
        let edge = min(originalWidth, originalHeight)
        
        let x = (originalWidth - edge) / 2.0
        let y = (originalHeight - edge) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: edge, height: edge)
        
        guard let cgImg = self.cgImage?.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: cgImg, scale: self.scale, orientation: self.imageOrientation)
    }
}
