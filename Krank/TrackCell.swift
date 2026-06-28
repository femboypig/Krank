//
//  TrackCell.swift
//  Krank
//

import UIKit

class TrackCell: UITableViewCell {
    static let identifier = "TrackCell"
    
    let mainHorizontalStack = UIStackView()
    let leftStack = UIStackView()
    let indexLabel = UILabel()
    let playingThumbnail = UIImageView()
    
    let textStack = UIStackView()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    
    let durationLabel = UILabel()
    let dividerLine = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playingThumbnail.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
        durationLabel.text = nil
        contentView.layer.transform = CATransform3DIdentity
        contentView.alpha = 1.0
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        mainHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        mainHorizontalStack.axis = .horizontal
        mainHorizontalStack.spacing = 12
        mainHorizontalStack.alignment = .center
        contentView.addSubview(mainHorizontalStack)
        
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center
        mainHorizontalStack.addArrangedSubview(leftStack)
        
        indexLabel.font = UIFont(name: "Georgia-Italic", size: 14)
        indexLabel.setContentHuggingPriority(.required, for: .horizontal)
        leftStack.addArrangedSubview(indexLabel)
        
        playingThumbnail.contentMode = .scaleAspectFill
        playingThumbnail.layer.cornerRadius = 4
        playingThumbnail.clipsToBounds = true
        playingThumbnail.layer.borderWidth = 0.5
        playingThumbnail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playingThumbnail.widthAnchor.constraint(equalToConstant: 28),
            playingThumbnail.heightAnchor.constraint(equalToConstant: 28)
        ])
        leftStack.addArrangedSubview(playingThumbnail)
        
        textStack.axis = .vertical
        textStack.spacing = 2
        mainHorizontalStack.addArrangedSubview(textStack)
        
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 14)
        textStack.addArrangedSubview(titleLabel)
        
        artistLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        textStack.addArrangedSubview(artistLabel)
        
        durationLabel.font = UIFont(name: "Georgia-Italic", size: 12)
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        durationLabel.textAlignment = .right
        mainHorizontalStack.addArrangedSubview(durationLabel)
        
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dividerLine)
        
        NSLayoutConstraint.activate([
            mainHorizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainHorizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainHorizontalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dividerLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dividerLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(with track: Track, index: Int, isPlaying: Bool, colors: ViewController) {
        titleLabel.textColor = colors.primaryTextColor()
        artistLabel.textColor = colors.secondaryTextColor()
        durationLabel.textColor = colors.secondaryTextColor()
        indexLabel.textColor = colors.secondaryTextColor()
        dividerLine.backgroundColor = colors.cardBorderColor()
        playingThumbnail.layer.borderColor = colors.cardBorderColor().cgColor
        
        indexLabel.text = String(format: "%02d", index + 1)
        titleLabel.text = track.title
        
        if track.artist != "Unknown Artist" && !track.artist.isEmpty {
            artistLabel.text = track.artist.uppercased()
            artistLabel.isHidden = false
        } else {
            artistLabel.text = ""
            artistLabel.isHidden = true
        }
        
        durationLabel.text = colors.formatTime(track.duration)
        
        if let artwork = track.artwork {
            playingThumbnail.image = artwork
            playingThumbnail.tintColor = nil
            playingThumbnail.backgroundColor = .clear
        } else {
            playingThumbnail.image = UIImage(named: "logo")
            playingThumbnail.tintColor = nil
            playingThumbnail.backgroundColor = .clear
        }
        
        if isPlaying {
            titleLabel.textColor = UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0)
            indexLabel.textColor = UIColor(red: 0.85, green: 0.36, blue: 0.22, alpha: 1.0)
            contentView.backgroundColor = colors.activeRowColor()
        } else {
            titleLabel.textColor = colors.primaryTextColor()
            indexLabel.textColor = colors.secondaryTextColor()
            contentView.backgroundColor = .clear
        }
    }
}
