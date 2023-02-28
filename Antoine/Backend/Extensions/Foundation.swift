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
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
}

extension Bundle {
    static func makeLocalizationBundle(preferredLanguageCode: String? = Preferences.preferredLanguageCode) -> Bundle {
        if let preferredLangCode = preferredLanguageCode,
           let bundle = Bundle(path: Bundle.main.path(forResource: preferredLangCode, ofType: "lproj")!) {
            return bundle
        }
        
        return Bundle.main
    }
    
    // MAKE SURE TO UPDATE THIS WHENEVER `Preferences.preferredLanguageCode` IS CHANGED!!
    static var preferredLocalizationBundle = makeLocalizationBundle()
}
extension String {
    static func localized(_ name: String) -> String {
        return NSLocalizedString(name, bundle: .preferredLocalizationBundle, comment: "")
    }
    
    static func localized(_ name: String, arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(name, bundle: .preferredLocalizationBundle, comment: ""), arguments: arguments)
    }
    
    func localized() -> String {
        return String.localized(self)
    }
}
