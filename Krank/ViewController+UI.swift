//
//  ViewController+UI.swift
//  Krank
//

import UIKit

extension ViewController {

    // MARK: - Claude / Anthropic Style Color Palette
    
    func primaryBackgroundColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0) : UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
        }
    }
    
    func cardBackgroundColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.11, blue: 0.10, alpha: 1.0) : UIColor(red: 0.985, green: 0.985, blue: 0.976, alpha: 1.0)
        }
    }
    
    func cardBorderColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.18, green: 0.17, blue: 0.16, alpha: 1.0) : UIColor(red: 0.90, green: 0.87, blue: 0.84, alpha: 1.0)
        }
    }
    
    func primaryTextColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 1.0) : UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
        }
    }
    
    func secondaryTextColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.66, green: 0.64, blue: 0.60, alpha: 1.0) : UIColor(red: 0.45, green: 0.41, blue: 0.36, alpha: 1.0)
        }
    }
    
    func progressTrackColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.18, green: 0.17, blue: 0.16, alpha: 1.0) : UIColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
        }
    }
    
    func primaryButtonColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 1.0) : UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
        }
    }
    
    func primaryButtonTextColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0) : UIColor(red: 0.985, green: 0.985, blue: 0.976, alpha: 1.0)
        }
    }
    
    func activeRowColor() -> UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 1.0) : UIColor(red: 0.97, green: 0.94, blue: 0.91, alpha: 1.0)
        }
    }
    
    // MARK: - UI Layout Setup
    
    func setupUI() {
        view.backgroundColor = primaryBackgroundColor()
        
        // Paging ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // Page Containers
        page0 = UIView()
        page0.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(page0)
        
        page1 = UIView()
        page1.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(page1)
        
        page2 = UIView()
        page2.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(page2)
        
        // Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            page0.topAnchor.constraint(equalTo: scrollView.topAnchor),
            page0.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            page0.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            page0.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            page0.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            page1.topAnchor.constraint(equalTo: scrollView.topAnchor),
            page1.leadingAnchor.constraint(equalTo: page0.trailingAnchor),
            page1.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            page1.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            page1.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            page2.topAnchor.constraint(equalTo: scrollView.topAnchor),
            page2.leadingAnchor.constraint(equalTo: page1.trailingAnchor),
            page2.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            page2.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            page2.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            page2.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        setupPage0Settings()
        setupPage1Library()
        setupPage2NowPlaying()
    }
    
    func setupPage0Settings() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 42)
        titleLabel.textColor = primaryTextColor()
        titleLabel.text = "Settings."
        page0.addSubview(titleLabel)
        
        // Settings Card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) : UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)
        }
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1.0
        card.layer.borderColor = cardBorderColor().cgColor
        page0.addSubview(card)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = primaryTextColor()
        label.text = "DJ Transitions"
        card.addSubview(label)
        
        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.text = "Beat-matches and crossfades songs smoothly 6 seconds before they end."
        card.addSubview(descLabel)
        
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        // Ensure default key exists
        if UserDefaults.standard.object(forKey: "Krank_AIDJEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "Krank_AIDJEnabled")
        }
        toggle.isOn = UserDefaults.standard.bool(forKey: "Krank_AIDJEnabled")
        toggle.onTintColor = UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0) // Copper
        toggle.addTarget(self, action: #selector(aidjToggleChanged(_:)), for: .valueChanged)
        card.addSubview(toggle)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: page0.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: page0.leadingAnchor, constant: 24),
            
            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            card.leadingAnchor.constraint(equalTo: page0.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: page0.trailingAnchor, constant: -24),
            card.heightAnchor.constraint(equalToConstant: 100),
            
            toggle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            toggle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -16),
            
            descLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -16)
        ])
    }
    
    @objc func aidjToggleChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "Krank_AIDJEnabled")
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func setupPage1Library() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 42)
        titleLabel.textColor = primaryTextColor()
        titleLabel.text = "Krank."
        page1.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont(name: "Georgia-Italic", size: 16)
        subtitleLabel.textColor = secondaryTextColor()
        subtitleLabel.text = "Your auditory shelf."
        page1.addSubview(subtitleLabel)
        
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search songs..."
        searchBar.delegate = self
        page1.addSubview(searchBar)
        
        // Horizontal Playlists/Favorites Pill Scroller
        filtersScrollView = UIScrollView()
        filtersScrollView.translatesAutoresizingMaskIntoConstraints = false
        filtersScrollView.showsHorizontalScrollIndicator = false
        filtersScrollView.bounces = true
        page1.addSubview(filtersScrollView)
        
        filtersStackView = UIStackView()
        filtersStackView.translatesAutoresizingMaskIntoConstraints = false
        filtersStackView.axis = .horizontal
        filtersStackView.spacing = 8
        filtersStackView.alignment = .center
        filtersScrollView.addSubview(filtersStackView)
        
        tableView = CylinderTableView()
        tableView.onLayoutSubviews = { [weak self] in
            self?.applyCylinderEffect()
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        page1.addSubview(tableView)
        
        // Apply drum-roll cylinder mask (fade top/bottom edges)
        applyTableGradientMask()
        
        // Add Custom Long-Press Gesture on Cells to replace native Context Menu
        let cellLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCellLongPress(_:)))
        tableView.addGestureRecognizer(cellLongPress)
        
        // --- Compact Floating Pill Miniplayer Card (Thinner style) ---
        miniPlayerView = UIView()
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.backgroundColor = cardBackgroundColor()
        miniPlayerView.layer.cornerRadius = 27
        miniPlayerView.layer.borderWidth = 1.0
        miniPlayerView.layer.borderColor = cardBorderColor().cgColor
        miniPlayerView.isUserInteractionEnabled = true
        
        // Floating cloud shadow
        miniPlayerView.layer.shadowColor = UIColor.black.cgColor
        miniPlayerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        miniPlayerView.layer.shadowOpacity = 0.08
        miniPlayerView.layer.shadowRadius = 8
        page1.addSubview(miniPlayerView)
        
        let miniTap = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped(_:)))
        miniPlayerView.addGestureRecognizer(miniTap)
        
        miniCoverCard = UIView()
        miniCoverCard.translatesAutoresizingMaskIntoConstraints = false
        miniCoverCard.layer.cornerRadius = 6
        miniCoverCard.clipsToBounds = true
        miniCoverCard.layer.borderWidth = 0.5
        miniCoverCard.layer.borderColor = cardBorderColor().cgColor
        miniPlayerView.addSubview(miniCoverCard)
        
        miniCoverView = UIImageView()
        miniCoverView.translatesAutoresizingMaskIntoConstraints = false
        miniCoverView.contentMode = .scaleAspectFill
        miniCoverView.clipsToBounds = true
        miniCoverCard.addSubview(miniCoverView)
        
        let miniTextStack = UIStackView()
        miniTextStack.translatesAutoresizingMaskIntoConstraints = false
        miniTextStack.axis = .vertical
        miniTextStack.spacing = 1
        miniPlayerView.addSubview(miniTextStack)
        
        miniTitleLabel = UILabel()
        miniTitleLabel.font = UIFont(name: "Georgia-Bold", size: 13)
        miniTitleLabel.textColor = primaryTextColor()
        miniTitleLabel.text = "No Track Selected"
        miniTextStack.addArrangedSubview(miniTitleLabel)
        
        miniArtistLabel = UILabel()
        miniArtistLabel.font = UIFont(name: "Georgia-Italic", size: 10)
        miniArtistLabel.textColor = secondaryTextColor()
        miniArtistLabel.text = "Select a song below"
        miniTextStack.addArrangedSubview(miniArtistLabel)
        
        let miniControls = UIStackView()
        miniControls.translatesAutoresizingMaskIntoConstraints = false
        miniControls.axis = .horizontal
        miniControls.spacing = 8
        miniControls.alignment = .center
        miniPlayerView.addSubview(miniControls)
        
        let miniPrevButton = UIButton(type: .system)
        miniPrevButton.translatesAutoresizingMaskIntoConstraints = false
        miniPrevButton.tintColor = primaryTextColor()
        miniPrevButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        miniPrevButton.addTarget(self, action: #selector(playPreviousTrack), for: .touchUpInside)
        miniControls.addArrangedSubview(miniPrevButton)
        
        miniPlayPauseButton = UIButton(type: .custom)
        miniPlayPauseButton.translatesAutoresizingMaskIntoConstraints = false
        miniPlayPauseButton.tintColor = primaryTextColor()
        miniPlayPauseButton.layer.cornerRadius = 15
        miniPlayPauseButton.layer.borderWidth = 1.0
        miniPlayPauseButton.layer.borderColor = cardBorderColor().cgColor
        miniPlayPauseButton.backgroundColor = cardBackgroundColor()
        miniPlayPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)), for: .normal)
        miniPlayPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        miniControls.addArrangedSubview(miniPlayPauseButton)
        
        miniNextButton = UIButton(type: .system)
        miniNextButton.translatesAutoresizingMaskIntoConstraints = false
        miniNextButton.tintColor = primaryTextColor()
        miniNextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        miniNextButton.addTarget(self, action: #selector(playNextTrack), for: .touchUpInside)
        miniControls.addArrangedSubview(miniNextButton)
        
        importButton = UIButton(type: .custom)
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.backgroundColor = primaryButtonColor()
        importButton.setTitleColor(primaryButtonTextColor(), for: .normal)
        importButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        importButton.layer.cornerRadius = 25.0
        importButton.setTitle("Import Music Files", for: .normal)
        importButton.addTarget(self, action: #selector(importMusicButtonTapped), for: .touchUpInside)
        page1.addSubview(importButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: page1.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 20),
            
            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: page1.trailingAnchor, constant: -12),
            
            // Filters Scroller constraints
            filtersScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filtersScrollView.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 16),
            filtersScrollView.trailingAnchor.constraint(equalTo: page1.trailingAnchor, constant: -16),
            filtersScrollView.heightAnchor.constraint(equalToConstant: 38),
            
            filtersStackView.topAnchor.constraint(equalTo: filtersScrollView.contentLayoutGuide.topAnchor),
            filtersStackView.bottomAnchor.constraint(equalTo: filtersScrollView.contentLayoutGuide.bottomAnchor),
            filtersStackView.leadingAnchor.constraint(equalTo: filtersScrollView.contentLayoutGuide.leadingAnchor),
            filtersStackView.trailingAnchor.constraint(equalTo: filtersScrollView.contentLayoutGuide.trailingAnchor),
            filtersStackView.heightAnchor.constraint(equalToConstant: 38),
            
            tableView.topAnchor.constraint(equalTo: filtersScrollView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: page1.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: page1.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: importButton.topAnchor, constant: -12),
            
            importButton.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 20),
            importButton.trailingAnchor.constraint(equalTo: page1.trailingAnchor, constant: -20),
            importButton.bottomAnchor.constraint(equalTo: miniPlayerView.topAnchor, constant: -16),
            importButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Floating Miniplayer card - Height 54pt
            miniPlayerView.leadingAnchor.constraint(equalTo: page1.leadingAnchor, constant: 16),
            miniPlayerView.trailingAnchor.constraint(equalTo: page1.trailingAnchor, constant: -16),
            miniPlayerView.bottomAnchor.constraint(equalTo: page1.bottomAnchor, constant: -16),
            miniPlayerView.heightAnchor.constraint(equalToConstant: 54),
            
            miniCoverCard.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor, constant: 12),
            miniCoverCard.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            miniCoverCard.widthAnchor.constraint(equalToConstant: 32),
            miniCoverCard.heightAnchor.constraint(equalToConstant: 32),
            
            miniCoverView.topAnchor.constraint(equalTo: miniCoverCard.topAnchor),
            miniCoverView.leadingAnchor.constraint(equalTo: miniCoverCard.leadingAnchor),
            miniCoverView.trailingAnchor.constraint(equalTo: miniCoverCard.trailingAnchor),
            miniCoverView.bottomAnchor.constraint(equalTo: miniCoverCard.bottomAnchor),
            
            miniTextStack.leadingAnchor.constraint(equalTo: miniCoverCard.trailingAnchor, constant: 12),
            miniTextStack.trailingAnchor.constraint(equalTo: miniControls.leadingAnchor, constant: -10),
            miniTextStack.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            
            miniControls.trailingAnchor.constraint(equalTo: miniPlayerView.trailingAnchor, constant: -16),
            miniControls.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            
            miniPrevButton.widthAnchor.constraint(equalToConstant: 26),
            miniPrevButton.heightAnchor.constraint(equalToConstant: 26),
            
            miniPlayPauseButton.widthAnchor.constraint(equalToConstant: 30),
            miniPlayPauseButton.heightAnchor.constraint(equalToConstant: 30),
            
            miniNextButton.widthAnchor.constraint(equalToConstant: 26),
            miniNextButton.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        // Centering low-priority layout constraint for category pills
        let centerConstraint = filtersStackView.centerXAnchor.constraint(equalTo: filtersScrollView.centerXAnchor)
        centerConstraint.priority = .defaultLow
        centerConstraint.isActive = true
        
        rebuildFiltersRow()
    }
    
    func setupPage2NowPlaying() {
        // Respect system background color (warm cream / charcoal)
        page2.backgroundColor = primaryBackgroundColor()
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        page2.addSubview(container)
        
        // Large Cover Art Card (White square container matching user's layout)
        coverArtCard = UIView()
        coverArtCard.translatesAutoresizingMaskIntoConstraints = false
        coverArtCard.backgroundColor = .white
        coverArtCard.layer.cornerRadius = 16
        coverArtCard.clipsToBounds = true
        container.addSubview(coverArtCard)
        
        coverImageView = UIImageView()
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverArtCard.addSubview(coverImageView)
        
        // Seek Bar (Sleek linear design)
        progressSlider = UISlider()
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.minimumTrackTintColor = UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0) // Copper accent
        progressSlider.maximumTrackTintColor = progressTrackColor()
        progressSlider.setThumbImage(makeThumbImage(size: 8), for: .normal)
        progressSlider.addTarget(self, action: #selector(sliderValueChanging(_:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderFinishedChanging(_:)), for: [.touchUpInside, .touchUpOutside])
        container.addSubview(progressSlider)
        
        elapsedLabel = UILabel()
        elapsedLabel.translatesAutoresizingMaskIntoConstraints = false
        elapsedLabel.font = UIFont(name: "Georgia-Italic", size: 12)
        elapsedLabel.textColor = secondaryTextColor()
        elapsedLabel.text = "0:00"
        container.addSubview(elapsedLabel)
        
        remainingLabel = UILabel()
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingLabel.font = UIFont(name: "Georgia-Italic", size: 12)
        remainingLabel.textColor = secondaryTextColor()
        remainingLabel.text = "-0:00"
        container.addSubview(remainingLabel)
        
        // Left aligned Combined Title label
        trackTitleLabel = UILabel()
        trackTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trackTitleLabel.font = UIFont(name: "Georgia-Bold", size: 20)
        trackTitleLabel.textColor = primaryTextColor()
        trackTitleLabel.textAlignment = .left
        trackTitleLabel.numberOfLines = 2
        trackTitleLabel.text = "No Track Selected"
        container.addSubview(trackTitleLabel)
        
        // Artist Label (replaces technical format details)
        artistLabel = UILabel()
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = UIFont(name: "Georgia-Italic", size: 15)
        artistLabel.textColor = secondaryTextColor()
        artistLabel.textAlignment = .left
        artistLabel.text = "Unknown Artist"
        container.addSubview(artistLabel)
        
        // Controls Row
        let controlsStack = UIStackView()
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsStack.axis = .horizontal
        controlsStack.alignment = .center
        controlsStack.distribution = .equalSpacing
        container.addSubview(controlsStack)
        
        // Left Column (Shuffle & Repeat stacked vertically)
        let leftSideStack = UIStackView()
        leftSideStack.axis = .vertical
        leftSideStack.spacing = 16
        leftSideStack.alignment = .center
        controlsStack.addArrangedSubview(leftSideStack)
        
        repeatButton = UIButton(type: .system)
        repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        repeatButton.tintColor = secondaryTextColor()
        repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        leftSideStack.addArrangedSubview(repeatButton)
        
        shuffleButton = UIButton(type: .system)
        shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        shuffleButton.tintColor = secondaryTextColor()
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        leftSideStack.addArrangedSubview(shuffleButton)
        
        // Center Controls Stack (Prev, Play, Next)
        let centerPlaybackStack = UIStackView()
        centerPlaybackStack.axis = .horizontal
        centerPlaybackStack.spacing = 28
        centerPlaybackStack.alignment = .center
        controlsStack.addArrangedSubview(centerPlaybackStack)
        
        let prevButton = UIButton(type: .system)
        prevButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)), for: .normal)
        prevButton.tintColor = primaryTextColor()
        prevButton.addTarget(self, action: #selector(playPreviousTrack), for: .touchUpInside)
        centerPlaybackStack.addArrangedSubview(prevButton)
        
        playPauseButton = UIButton(type: .custom)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.tintColor = primaryTextColor()
        playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        centerPlaybackStack.addArrangedSubview(playPauseButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)), for: .normal)
        nextButton.tintColor = primaryTextColor()
        nextButton.addTarget(self, action: #selector(playNextTrack), for: .touchUpInside)
        centerPlaybackStack.addArrangedSubview(nextButton)
        
        // Right Side Column (Symmetrical layout: Heart above Options)
        let rightSideStack = UIStackView()
        rightSideStack.axis = .vertical
        rightSideStack.spacing = 16
        rightSideStack.alignment = .center
        controlsStack.addArrangedSubview(rightSideStack)
        
        playerFavoriteButton = UIButton(type: .system)
        playerFavoriteButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        playerFavoriteButton.tintColor = secondaryTextColor()
        playerFavoriteButton.addTarget(self, action: #selector(playerFavoriteTapped), for: .touchUpInside)
        rightSideStack.addArrangedSubview(playerFavoriteButton)
        
        // Right Side Options Menu (...)
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        optionsButton.tintColor = secondaryTextColor()
        optionsButton.addTarget(self, action: #selector(optionsTapped), for: .touchUpInside)
        rightSideStack.addArrangedSubview(optionsButton)
        
        // Constraints targeting user's layout
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: page2.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: page2.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: page2.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(equalTo: page2.trailingAnchor, constant: -24),
            
            coverArtCard.topAnchor.constraint(equalTo: container.topAnchor),
            coverArtCard.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            coverArtCard.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            coverArtCard.heightAnchor.constraint(equalTo: coverArtCard.widthAnchor),
            
            coverImageView.topAnchor.constraint(equalTo: coverArtCard.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverArtCard.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverArtCard.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverArtCard.bottomAnchor),
            
            progressSlider.topAnchor.constraint(equalTo: coverArtCard.bottomAnchor, constant: 24),
            progressSlider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            elapsedLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 6),
            elapsedLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            
            remainingLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 6),
            remainingLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            
            trackTitleLabel.topAnchor.constraint(equalTo: elapsedLabel.bottomAnchor, constant: 20),
            trackTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trackTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            artistLabel.topAnchor.constraint(equalTo: trackTitleLabel.bottomAnchor, constant: 6),
            artistLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            controlsStack.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 36),
            controlsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controlsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controlsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    func updateCardBorders() {
        let border = cardBorderColor().cgColor
        miniPlayerView.layer.borderColor = border
        miniCoverCard.layer.borderColor = border
        miniPlayPauseButton.layer.borderColor = border
        
        // Re-set slider thumbs to ensure alignment
        progressSlider.setThumbImage(makeThumbImage(size: 8), for: .normal)
    }
    
    func makeThumbImage(size: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0).cgColor)
        context?.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Cylinder / Drum-Roll Fade Overlays
    
    func applyTableGradientMask() {
        page1.viewWithTag(7701)?.removeFromSuperview()
        page1.viewWithTag(7702)?.removeFromSuperview()
        
        let topFade = GradientOverlayView(fromTop: true) { [weak self] in
            self?.primaryBackgroundColor() ?? .clear
        }
        topFade.tag = 7701
        page1.addSubview(topFade)
        
        let bottomFade = GradientOverlayView(fromTop: false) { [weak self] in
            self?.primaryBackgroundColor() ?? .clear
        }
        bottomFade.tag = 7702
        page1.addSubview(bottomFade)
        
        page1.setNeedsLayout()
    }
    
    func updateTableGradientMaskFrame() {
        guard let top = page1?.viewWithTag(7701) as? GradientOverlayView,
              let bot = page1?.viewWithTag(7702) as? GradientOverlayView else { return }
        
        let tableFrame = tableView.frame
        let fadeHeight: CGFloat = 36
        
        // Position overlays precisely over the tableView edges
        top.frame = CGRect(x: tableFrame.minX, y: tableFrame.minY,
                           width: tableFrame.width, height: fadeHeight)
        bot.frame = CGRect(x: tableFrame.minX, y: tableFrame.maxY - fadeHeight,
                           width: tableFrame.width, height: fadeHeight)
        
        top.setNeedsLayout()
        top.layoutIfNeeded()
        bot.setNeedsLayout()
        bot.layoutIfNeeded()
    }
}

// MARK: - GradientOverlayView Class

class GradientOverlayView: UIView {
    private let gradient = CAGradientLayer()
    private let fromTop: Bool
    private let colorProvider: () -> UIColor
    
    init(fromTop: Bool, colorProvider: @escaping () -> UIColor) {
        self.fromTop = fromTop
        self.colorProvider = colorProvider
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        self.layer.addSublayer(gradient)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
        
        let bg = colorProvider().resolvedColor(with: self.traitCollection)
        let transparentBg = bg.withAlphaComponent(0.0)
        
        if fromTop {
            // Solid color for first 30% of height, then fades out to transparent
            gradient.colors = [bg.cgColor, bg.cgColor, transparentBg.cgColor]
            gradient.locations = [0.0, 0.3, 1.0]
        } else {
            // Transparent for first 70% of height, then solid color for the final 30%
            gradient.colors = [transparentBg.cgColor, bg.cgColor, bg.cgColor]
            gradient.locations = [0.0, 0.7, 1.0]
        }
    }
}
