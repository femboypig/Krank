//
//  ViewController.swift
//  Krank
//
//  Created by Mac on 27.06.2026.
//

import UIKit
import AVFoundation
import MediaPlayer
import UniformTypeIdentifiers

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIDocumentPickerDelegate, AVAudioPlayerDelegate {

    // Category association key for Objective-C runtime
    static var categoryAssociationKey: UInt8 = 0
    static var textAssociationKey: UInt8 = 1

    // Swipable Container
    var scrollView: UIScrollView!
    
    // Page 0 (Settings) & Page 1 (Library) Subviews
    var page0: UIView!
    var page1: UIView!
    var tableView: CylinderTableView!
    var searchBar: UISearchBar!
    var importButton: UIButton!
    
    // Horizontal Playlists/Favorites Pill Scroller
    var filtersScrollView: UIScrollView!
    var filtersStackView: UIStackView!
    
    // Custom Bottom Sheet Active States
    var activeDimmedBg: UIView?
    var activeSheetView: UIView?
    var activeSheetBottomConstraint: NSLayoutConstraint?
    
    // Miniplayer (Page 1 Interface - Floating Pill Card)
    var miniPlayerView: UIView!
    var miniCoverCard: UIView!
    var miniCoverView: UIImageView!
    var miniTitleLabel: UILabel!
    var miniArtistLabel: UILabel!
    var miniPlayPauseButton: UIButton!
    var miniNextButton: UIButton!
    
    // Page 2 (Now Playing) Subviews
    var page2: UIView!
    var coverArtCard: UIView!
    var coverImageView: UIImageView!
    var trackTitleLabel: UILabel!
    var artistLabel: UILabel!
    var progressSlider: UISlider!
    var elapsedLabel: UILabel!
    var remainingLabel: UILabel!
    var playPauseButton: UIButton!
    var shuffleButton: UIButton!
    var repeatButton: UIButton!
    var playerFavoriteButton: UIButton!
    var volumeSlider: UISlider!
    
    // Playback State & Audio Player
    var tracks: [Track] = []
    var filteredTracks: [Track] = []
    var currentTrackIndex: Int? {
        didSet {
            savePlaybackState()
        }
    }
    var audioPlayer: AVAudioPlayer?
    var updateTimer: Timer?
    var sleepTimer: Timer?
    
    // Shuffle Queue State
    var shuffledIndices: [Int] = []
    var shuffledPosition: Int = 0
    
    // Haptics & Drum Centering State
    var lastCenterRow: Int?
    let scrollFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let aidj = AIDJTransitionCoordinator()
    var didInitialScroll = false
    
    // Favorites & Playlists Local Data Store
    var favoriteTracks: Set<String> = []
    var playlists: [String: [String]] = [:] // mapping Playlist Name -> Track Filenames
    
    enum FilterCategory: Equatable {
        case all
        case favorites
        case playlist(String)
    }
    var activeFilter: FilterCategory = .all
    
    var isShuffleEnabled = false {
        didSet {
            UserDefaults.standard.set(isShuffleEnabled, forKey: "Krank_Shuffle")
            updatePlaybackButtons()
            if isShuffleEnabled {
                rebuildShuffleQueue()
            }
        }
    }
    
    var isRepeatEnabled = false {
        didSet {
            UserDefaults.standard.set(isRepeatEnabled, forKey: "Krank_Repeat")
            updatePlaybackButtons()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLocalUserData()
        setupAudioSession()
        setupRemoteCommands()
        setupUI()
        loadLocalTracks()
        loadPlaybackState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCardBorders()
        updateTableGradientMaskFrame()
        applyCylinderEffect()
        updateFilterPillBorders()
        updateOverlayAlphas()
        
        if !didInitialScroll && scrollView.frame.size.width > 0 {
            didInitialScroll = true
            let width = scrollView.frame.size.width
            scrollView.contentOffset = CGPoint(x: width, y: 0)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTableGradientMaskFrame()
            updateFilterPillBorders()
        }
    }
}
