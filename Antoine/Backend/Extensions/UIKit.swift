//
//  UIKitExtensions.swift
//  Antoine
//
//  Created by Serena on 18/01/2023.
//

import UIKit

extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    
    convenience init(text: String, font: UIFont?, textColor: UIColor?) {
        self.init(text: text)
        self.textColor = textColor
        self.font = font
    }
}

// Support for closure-based addAction / addTarget functions
// for iOS 13
extension UIControl {
    func addAction(for event: UIControl.Event, _ closure: @escaping () -> Void) {
        if #available(iOS 14.0, *) {
            let uiAction = UIAction { _ in closure() }
            addAction(uiAction, for: event)
            return
        }
        
        @objc class ClosureSleeve: NSObject {
            let closure: () -> Void
            init(_ closure: @escaping () -> Void) { self.closure = closure }
            @objc func invoke() { closure() }
        }
        
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: event)
        objc_setAssociatedObject(self, UUID().uuidString, sleeve, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension UIViewController {
    func errorAlert(
        title: String,
        description: String?,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel)]) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
    
    func export(entry: Entry, senderView: UIView, senderRect: CGRect) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
            let serialized = try encoder.encode(CodableEntry(streamEntry: entry))
            let docsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Antoine Logs")
            try FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true) /* if dir doesn't already exist */
            let fileURL = docsURL
                .appendingPathComponent(
                    "\(entry.process) (\(DateFormatter(dateFormat: "MMM d h:mm a").string(from: entry.timestamp)))"
                )
                .appendingPathExtension("antoinelog")
            
            if FileManager.default.createFile(atPath: fileURL.path, contents: serialized) {
                let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                
                vc.popoverPresentationController?.sourceView = senderView
                vc.popoverPresentationController?.sourceRect = /*sender.frame*/senderRect
                present(vc, animated: true)
            } else {
                errorAlert(title: .localized("Failed to create log file"), description: nil)
            }
        } catch {
            errorAlert(title: .localized("Error creating log file"), description: error.localizedDescription)
        }
    }
}

extension NSDiffableDataSourceSnapshot {
    mutating func reloadItems(inSection section: SectionIdentifierType, rebuildWith newItems: [ItemIdentifierType]) {
        deleteItems(itemIdentifiers(inSection: section))
        appendItems(newItems, toSection: section)
    }
}

extension UITableViewCell {
    func addChoiceButton(
        text: String,
        image: UIImage?,
        buttonHandler: (UIButton) -> Void) {
        let button: UIButton
        let buttonTrailingAnchor: NSLayoutXAxisAnchor
        
        if #available(iOS 15.0, *) {
            var conf: UIButton.Configuration = .plain()
            conf.image = image
            conf.title = text
            conf.imagePadding = 5
            
            button = UIButton(configuration: conf)
            
            buttonTrailingAnchor = contentView.trailingAnchor
        } else {
            button = UIButton(type: .system)
            button.setTitle(text, for: .normal)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets.left = -10
            
            buttonTrailingAnchor = contentView
                .layoutMarginsGuide
                .trailingAnchor
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(button)
        
        buttonHandler(button)
        
        // on iOS 15, when using button configurations, it's somehow automatically aligned to the inner side
        // without using a margins guide
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: buttonTrailingAnchor),
            button.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor)
        ])
    }
}

extension UIBarButtonItem {
    static func space(_ type: Space) -> UIBarButtonItem {
        switch type {
        case .flexible:
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        case .fixed(let width):
            let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            item.width = width
            return item
        }
    }
    
    enum Space: Hashable {
        case flexible
        case fixed(CGFloat)
    }
}
