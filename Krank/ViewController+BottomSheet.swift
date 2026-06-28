//
//  ViewController+BottomSheet.swift
//  Krank
//

import UIKit

extension ViewController {

    // MARK: - Custom Bottom Sheet Presentation Engine (Floating Island Capsule style)
    
    func presentCustomBottomSheet(title: String, subtitle: String? = nil, items: [BottomSheetItem]) {
        dismissActiveSheet { [weak self] in
            guard let self = self else { return }
            self.setupAndPresentSheet(title: title, subtitle: subtitle, items: items)
        }
    }
    
    func setupAndPresentSheet(title: String, subtitle: String?, items: [BottomSheetItem]) {
        let dimmedBg = UIView()
        dimmedBg.translatesAutoresizingMaskIntoConstraints = false
        dimmedBg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedBg.alpha = 0.0
        view.addSubview(dimmedBg)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCustomBottomSheet))
        dimmedBg.addGestureRecognizer(tap)
        
        let sheetView = UIView()
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = cardBackgroundColor()
        sheetView.layer.cornerRadius = 22
        sheetView.layer.borderWidth = 1.0
        sheetView.layer.borderColor = cardBorderColor().cgColor
        
        // Floating shadow
        sheetView.layer.shadowColor = UIColor.black.cgColor
        sheetView.layer.shadowOffset = CGSize(width: 0, height: 8)
        sheetView.layer.shadowOpacity = 0.08
        sheetView.layer.shadowRadius = 12
        sheetView.clipsToBounds = false
        view.addSubview(sheetView)
        
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.alignment = .fill
        sheetView.addSubview(contentStack)
        
        let titleHeader = UIView()
        titleHeader.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleHeader)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 16)
        titleLabel.textColor = primaryTextColor()
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleHeader.addSubview(titleLabel)
        
        var lastAnchor = titleLabel.bottomAnchor
        
        if let sub = subtitle {
            let subLabel = UILabel()
            subLabel.translatesAutoresizingMaskIntoConstraints = false
            subLabel.font = UIFont(name: "Georgia-Italic", size: 12)
            subLabel.textColor = secondaryTextColor()
            subLabel.text = sub
            subLabel.textAlignment = .left
            titleHeader.addSubview(subLabel)
            
            NSLayoutConstraint.activate([
                subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
                subLabel.leadingAnchor.constraint(equalTo: titleHeader.leadingAnchor, constant: 20),
                subLabel.trailingAnchor.constraint(equalTo: titleHeader.trailingAnchor, constant: -20)
            ])
            lastAnchor = subLabel.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleHeader.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: titleHeader.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: titleHeader.trailingAnchor, constant: -20),
            lastAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: -16)
        ])
        
        let headerDivider = UIView()
        headerDivider.backgroundColor = cardBorderColor()
        headerDivider.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerDivider)
        headerDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        for (index, item) in items.enumerated() {
            let btnContainer = UIView()
            btnContainer.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview(btnContainer)
            
            let btn = UIButton(type: .custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btnContainer.addSubview(btn)
            
            let elementStack = UIStackView()
            elementStack.translatesAutoresizingMaskIntoConstraints = false
            elementStack.axis = .horizontal
            elementStack.spacing = 14
            elementStack.alignment = .center
            elementStack.distribution = .fill
            elementStack.isUserInteractionEnabled = false
            btn.addSubview(elementStack)
            
            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.contentMode = .scaleAspectFit
            icon.tintColor = item.isDestructive ? .systemRed : secondaryTextColor()
            icon.image = UIImage(systemName: item.iconName)
            icon.setContentHuggingPriority(.required, for: .horizontal)
            elementStack.addArrangedSubview(icon)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Georgia-Bold", size: 14)
            label.textColor = item.isDestructive ? .systemRed : primaryTextColor()
            label.text = item.title
            label.textAlignment = .left
            elementStack.addArrangedSubview(label)
            
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: btnContainer.topAnchor),
                btn.bottomAnchor.constraint(equalTo: btnContainer.bottomAnchor),
                btn.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
                btn.heightAnchor.constraint(equalToConstant: 52),
                
                elementStack.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 20),
                elementStack.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -20),
                elementStack.topAnchor.constraint(equalTo: btn.topAnchor),
                elementStack.bottomAnchor.constraint(equalTo: btn.bottomAnchor),
                
                icon.widthAnchor.constraint(equalToConstant: 18),
                icon.heightAnchor.constraint(equalToConstant: 18)
            ])
            
            btn.addTarget(self, action: #selector(bottomSheetItemTapped(_:)), for: .touchUpInside)
            objc_setAssociatedObject(btn, &ViewController.categoryAssociationKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if index < items.count - 1 {
                let div = UIView()
                div.backgroundColor = cardBorderColor()
                div.translatesAutoresizingMaskIntoConstraints = false
                contentStack.addArrangedSubview(div)
                div.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            }
        }
        
        self.activeDimmedBg = dimmedBg
        self.activeSheetView = sheetView
        
        // Floating layout margins (16pt gap from bottom, left, right)
        self.activeSheetBottomConstraint = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 450)
        
        NSLayoutConstraint.activate([
            dimmedBg.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.activeSheetBottomConstraint!,
            
            contentStack.topAnchor.constraint(equalTo: sheetView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor)
        ])
        
        view.layoutIfNeeded()
        
        self.activeSheetBottomConstraint?.constant = -16
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [], animations: {
            dimmedBg.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func bottomSheetItemTapped(_ sender: UIButton) {
        guard let item = objc_getAssociatedObject(sender, &ViewController.categoryAssociationKey) as? BottomSheetItem else { return }
        dismissActiveSheet {
            item.action()
        }
    }
    
    // MARK: - Custom Modal TextInput Sheet Presentation (Floating Island Capsule style)
    
    func presentCustomInputSheet(title: String, placeholder: String, submitTitle: String, onSubmit: @escaping (String) -> Void) {
        dismissActiveSheet { [weak self] in
            guard let self = self else { return }
            self.setupAndPresentInputSheet(title: title, placeholder: placeholder, submitTitle: submitTitle, onSubmit: onSubmit)
        }
    }
    
    func setupAndPresentInputSheet(title: String, placeholder: String, submitTitle: String, onSubmit: @escaping (String) -> Void) {
        let dimmedBg = UIView()
        dimmedBg.translatesAutoresizingMaskIntoConstraints = false
        dimmedBg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedBg.alpha = 0.0
        view.addSubview(dimmedBg)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCustomBottomSheet))
        dimmedBg.addGestureRecognizer(tap)
        
        let sheetView = UIView()
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = cardBackgroundColor()
        sheetView.layer.cornerRadius = 22
        sheetView.layer.borderWidth = 1.0
        sheetView.layer.borderColor = cardBorderColor().cgColor
        
        // Floating shadow
        sheetView.layer.shadowColor = UIColor.black.cgColor
        sheetView.layer.shadowOffset = CGSize(width: 0, height: 8)
        sheetView.layer.shadowOpacity = 0.08
        sheetView.layer.shadowRadius = 12
        sheetView.clipsToBounds = false
        view.addSubview(sheetView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 16)
        titleLabel.textColor = primaryTextColor()
        titleLabel.text = title
        titleLabel.textAlignment = .left
        sheetView.addSubview(titleLabel)
        
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = primaryBackgroundColor()
        textField.textColor = primaryTextColor()
        textField.font = UIFont(name: "Georgia-Italic", size: 15)
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = cardBorderColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        sheetView.addSubview(textField)
        
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        sheetView.addSubview(buttonStack)
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.titleLabel?.font = UIFont(name: "Georgia-Bold", size: 14)
        cancelBtn.setTitleColor(secondaryTextColor(), for: .normal)
        cancelBtn.layer.cornerRadius = 12
        cancelBtn.layer.borderWidth = 1.0
        cancelBtn.layer.borderColor = cardBorderColor().cgColor
        cancelBtn.addTarget(self, action: #selector(dismissCustomBottomSheet), for: .touchUpInside)
        buttonStack.addArrangedSubview(cancelBtn)
        
        let submitBtn = UIButton(type: .custom)
        submitBtn.setTitle(submitTitle, for: .normal)
        submitBtn.titleLabel?.font = UIFont(name: "Georgia-Bold", size: 14)
        submitBtn.setTitleColor(primaryButtonTextColor(), for: .normal)
        submitBtn.backgroundColor = primaryButtonColor()
        submitBtn.layer.cornerRadius = 12
        buttonStack.addArrangedSubview(submitBtn)
        
        let wrapper = InputSubmitWrapper(onSubmit)
        objc_setAssociatedObject(submitBtn, &ViewController.categoryAssociationKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(submitBtn, &ViewController.textAssociationKey, textField, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        submitBtn.addTarget(self, action: #selector(customInputSubmitted(_:)), for: .touchUpInside)
        
        self.activeDimmedBg = dimmedBg
        self.activeSheetView = sheetView
        self.activeSheetBottomConstraint = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 450)
        
        NSLayoutConstraint.activate([
            dimmedBg.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.activeSheetBottomConstraint!,
            
            titleLabel.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            buttonStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -20)
        ])
        
        view.layoutIfNeeded()
        
        self.activeSheetBottomConstraint?.constant = -16
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [], animations: {
            dimmedBg.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { _ in
            textField.becomeFirstResponder()
        }
    }
    
    @objc func customInputSubmitted(_ sender: UIButton) {
        guard let wrapper = objc_getAssociatedObject(sender, &ViewController.categoryAssociationKey) as? InputSubmitWrapper,
              let textField = objc_getAssociatedObject(sender, &ViewController.textAssociationKey) as? UITextField,
              let text = textField.text, !text.isEmpty else { return }
        
        dismissActiveSheet {
            wrapper.action(text)
        }
    }
    
    func dismissActiveSheet(completion: (() -> Void)? = nil) {
        guard let bg = activeDimmedBg, let sheet = activeSheetView else {
            completion?()
            return
        }
        
        activeSheetBottomConstraint?.constant = 450
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseIn, animations: {
            bg.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            bg.removeFromSuperview()
            sheet.removeFromSuperview()
            self.activeDimmedBg = nil
            self.activeSheetView = nil
            self.activeSheetBottomConstraint = nil
            completion?()
        }
    }
    
    @objc func dismissCustomBottomSheet() {
        dismissActiveSheet()
    }
    
    func showAddToPlaylistSelector(track: Track) {
        if playlists.isEmpty {
            presentCustomInputSheet(title: "New Playlist", placeholder: "Playlist Name", submitTitle: "Create") { [weak self] name in
                self?.playlists[name] = [track.url.lastPathComponent]
                self?.savePlaylists()
                self?.rebuildFiltersRow()
                self?.showToast(message: "Created and added to \(name)", success: true)
            }
            return
        }
        
        var items = [BottomSheetItem]()
        for name in playlists.keys.sorted() {
            items.append(BottomSheetItem(title: name, iconName: "music.note.list", isDestructive: false, action: { [weak self] in
                var list = self?.playlists[name] ?? []
                let filename = track.url.lastPathComponent
                if !list.contains(filename) {
                    list.append(filename)
                    self?.playlists[name] = list
                    self?.savePlaylists()
                    self?.showToast(message: "Added to \(name)", success: true)
                } else {
                    self?.showToast(message: "Already in \(name)", success: false)
                }
            }))
        }
        
        presentCustomBottomSheet(title: "Add to Playlist", subtitle: track.title, items: items)
    }
    
    // MARK: - Sleep Timer Selector
    
    func showSleepTimerSelector() {
        let options: [(String, Double)] = [
            ("15 Minutes", 15.0),
            ("30 Minutes", 30.0),
            ("45 Minutes", 45.0),
            ("60 Minutes", 60.0)
        ]
        
        var items = options.map { (title, mins) -> BottomSheetItem in
            return BottomSheetItem(title: title, iconName: "timer", isDestructive: false, action: { [weak self] in
                self?.startSleepTimer(minutes: mins)
            })
        }
        
        items.append(BottomSheetItem(title: "Custom Time", iconName: "pencil", isDestructive: false, action: { [weak self] in
            self?.showCustomSleepTimerPrompt()
        }))
        
        if sleepTimer != nil {
            items.append(BottomSheetItem(title: "Cancel Active Timer", iconName: "timer.badge.minus", isDestructive: true, action: { [weak self] in
                self?.sleepTimer?.invalidate()
                self?.sleepTimer = nil
                self?.showToast(message: "Sleep timer cancelled", success: true)
            }))
        }
        
        presentCustomBottomSheet(title: "Sleep Timer", subtitle: "Select when to stop playback", items: items)
    }
    
    func showCustomSleepTimerPrompt() {
        presentCustomInputSheet(title: "Custom Sleep Timer", placeholder: "Minutes", submitTitle: "Set") { [weak self] text in
            if let mins = Double(text), mins > 0 {
                self?.startSleepTimer(minutes: mins)
            } else {
                self?.showToast(message: "Invalid duration", success: false)
            }
        }
    }
    
    func startSleepTimer(minutes: Double) {
        sleepTimer?.invalidate()
        let seconds = minutes * 60
        sleepTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            self?.stopPlaybackDueToSleepTimer()
        }
        showToast(message: "Timer set for \(Int(minutes)) minutes", success: true)
    }
    
    func stopPlaybackDueToSleepTimer() {
        guard let player = audioPlayer, player.isPlaying else {
            sleepTimer = nil
            return
        }
        
        let initialVolume = player.volume
        var currentFadeStep = 0
        let totalSteps = 20
        let interval = 0.25 // 5 seconds total fade out
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentFadeStep += 1
            let progress = Float(totalSteps - currentFadeStep) / Float(totalSteps)
            player.volume = initialVolume * progress
            
            if currentFadeStep >= totalSteps {
                timer.invalidate()
                player.pause()
                player.volume = initialVolume // Restore volume
                
                self.playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)), for: .normal)
                self.stopArtworkAnimation()
                self.updateNowPlayingInfo()
                self.updateMiniPlayerUI()
                self.sleepTimer = nil
            }
        }
    }
    
    // MARK: - Options Menu Handler (ellipsis tapping)
    
    @objc func optionsTapped() {
        guard let index = currentTrackIndex, index < filteredTracks.count else { return }
        let track = filteredTracks[index]
        
        var items = [
            BottomSheetItem(title: "Share Song", iconName: "square.and.arrow.up", isDestructive: false, action: { [weak self] in
                let shareVC = UIActivityViewController(activityItems: [track.url], applicationActivities: nil)
                self?.present(shareVC, animated: true)
            }),
            BottomSheetItem(title: "Add to Playlist", iconName: "plus.circle", isDestructive: false, action: { [weak self] in
                self?.showAddToPlaylistSelector(track: track)
            }),
            BottomSheetItem(title: "Sleep Timer", iconName: "timer", isDestructive: false, action: { [weak self] in
                self?.showSleepTimerSelector()
            })
        ]
        
        if case .playlist(let playlistName) = activeFilter {
            items.append(BottomSheetItem(title: "Remove from \(playlistName)", iconName: "minus.circle", isDestructive: true, action: { [weak self] in
                self?.removeFromPlaylist(track: track, name: playlistName)
            }))
        }
        
        items.append(BottomSheetItem(title: "Delete Song", iconName: "trash", isDestructive: true, action: { [weak self] in
            self?.deleteTrack(at: index)
        }))
        
        presentCustomBottomSheet(title: track.title, subtitle: track.artist, items: items)
    }
}
