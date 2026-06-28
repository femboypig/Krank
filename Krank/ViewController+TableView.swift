//
//  ViewController+TableView.swift
//  Krank
//

import UIKit

extension ViewController {

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        let track = filteredTracks[indexPath.row]
        let isPlaying = (currentTrackIndex == indexPath.row && audioPlayer != nil)
        
        cell.configure(with: track, index: indexPath.row, isPlaying: isPlaying, colors: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTrackIndex = indexPath.row
        if isShuffleEnabled {
            rebuildShuffleQueue()
        }
        playCurrentTrack()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // Disabled native context menus to completely allow horizontal swipe transitions with zero conflicts
        return nil
    }
    
    // MARK: - Cell Long Press Gesture Handler
    
    @objc func handleCellLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let track = filteredTracks[indexPath.row]
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)
        
        let items = [
            BottomSheetItem(title: "Add to Playlist", iconName: "plus.circle", isDestructive: false, action: { [weak self] in
                self?.showAddToPlaylistSelector(track: track)
            }),
            BottomSheetItem(title: "Share Song", iconName: "square.and.arrow.up", isDestructive: false, action: { [weak self] in
                let shareVC = UIActivityViewController(activityItems: [track.url], applicationActivities: nil)
                self?.present(shareVC, animated: true)
            }),
            BottomSheetItem(title: "Delete Song", iconName: "trash", isDestructive: true, action: { [weak self] in
                self?.deleteTrack(at: indexPath.row)
            })
        ]
        
        presentCustomBottomSheet(title: track.title, subtitle: track.artist, items: items)
    }
}

// MARK: - CylinderTableView Subclass

class CylinderTableView: UITableView {
    var onLayoutSubviews: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews?()
    }
}
