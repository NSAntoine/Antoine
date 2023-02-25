//
//  BackgroundMode.swift
//  Antoine
//
//  Created by Serena on 12/02/2023.
//

import Foundation

enum BackgroundMode: Codable, Hashable, CustomStringConvertible {
    /// Keep collecting logs for a certain amount of seconds
    case backgroundTime(TimeInterval)
    
    /// Keep collecting logs in the background until the user opens the app again
    case indefinitely
    
    var description: String {
        switch self {
        case .backgroundTime(let time):
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            formatter.calendar = .current
            
            if let languageCode = Preferences.preferredLanguageCode {
                formatter.calendar?.locale = .init(
                    identifier: "\(languageCode)_\(Locale.current.regionCode ?? "US")"
                )
            }
            
            return formatter.string(from: time)!
        case .indefinitely:
            return .localized("Until manually disabled")
        }
    }
}
