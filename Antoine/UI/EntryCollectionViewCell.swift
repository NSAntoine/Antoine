//
//  EntryCollectionViewCell.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import UIKit

/// A UICollectionViewCell displaying basic information about a ``StreamEntry``,
/// including metadata and it's message
class EntryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties and UI
    
    var message: StreamEntry?
    
    var nameLabel: UILabel!
    var messageLabel: UILabel!
    
    func configure(message: StreamEntry) {
        self.message = message
        
//        if #available(iOS 14, *) {
//            backgroundConfiguration = EntryCollectionViewCell.backgroundConfiguration
//        } else {
            backgroundColor = EntryCollectionViewCell.cellBackgroundColor
            layer.cornerRadius = EntryCollectionViewCell.cellCornerRadius
//        }
        
        // process name label
        self.nameLabel = UILabel(text: message.process,
                                 font: Self.processNameLabelFont,
                                 textColor: message.type?.displayColor)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.messageLabel = UILabel(text: message.eventMessage, font: Self.messageTextFont, textColor: .secondaryLabel)
        messageLabel.numberOfLines = 2
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        messageLabel.text = nil
        message = nil
    }
    
    override var reuseIdentifier: String? {
        return Self.reuseIdentifier
    }
}

extension EntryCollectionViewCell {
    // MARK: - Static properties for utilities to show for each cell
    static let reuseIdentifier = "MessageCell"
    
    // Background Configuration (currently unused right now)
    @available(iOS 14, *)
    static let backgroundConfiguration = _makeDefaultBackgroundConf()
    static let cellCornerRadius: CGFloat = 14
    
    //static let dateFormatter = DateFormatter(dateFormat: "HH:mm:ss")
    
    static let messageTextFont: UIFont = UIFontMetrics.default.scaledFont(
        for: .systemFont(ofSize: 15, weight: .regular)
    )
    
    static let processNameLabelFont: UIFont = .preferredFont(forTextStyle: .headline)
    //static let pidLabelFont: UIFont = .preferredFont(forTextStyle: .caption2)
    
    static let cellBackgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .light:
            return .white
        default:
            return .quaternarySystemFill
        }
    }
    
    @available(iOS 14, *)
    private static func _makeDefaultBackgroundConf() -> UIBackgroundConfiguration {
        var conf = UIBackgroundConfiguration.clear()
        conf.backgroundColor = cellBackgroundColor
        conf.cornerRadius = 14
        return conf
    }
}
