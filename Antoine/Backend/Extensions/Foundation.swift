//
//  Foundation.swift
//  Antoine
//
//  Created by Serena on 18/01/2023.
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension Notification.Name {
    /// For when the timer interval for ``StreamViewController`` changes
    static var streamTimerIntervalDidChange: Notification.Name {
        return NSNotification.Name("timerIntervalDidChange")
    }
    
	/// DEPRECATED.
    static var backgroundModeChanged: Notification.Name {
        return NSNotification.Name("backgroundModeChanged")
    }
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
}

extension String {
    static func localized(_ name: String) -> String {
        return NSLocalizedString(name, comment: "")
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
