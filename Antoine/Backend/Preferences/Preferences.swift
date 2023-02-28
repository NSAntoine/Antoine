//
//  Preferences.swift
//  Antoine
//
//  Created by Serena on 10/12/2022
//

import Foundation
import CoreLocation

/// A set of user controlled preferences.
enum Preferences {
    @Storage(key: "StreamControllerTimerInterval", defaultValue: 1.0, callback: _timerIntervalCallback)
    static var streamVCTimerInterval: TimeInterval
    
	#warning("Fix the split view controller fucking mess on iPad so that this can be true")
    /// whether or not to use split views on iPad
    @Storage(key: "UseiPadMode", defaultValue: false)
    static var useiPadMode: Bool
    
    @CodableStorage(key: "EntryFilter", defaultValue: nil)
    static var entryFilter: EntryFilter?
    
    /// Language code of user preferred language, if there is one.
    @Storage(key: "UserPreferredLanguageCode", defaultValue: nil, callback: preferredLangChangedCallback)
    static var preferredLanguageCode: String?
    
    /// Whether or not to keep taking in log entries while the app is in the background.
    @Storage(key: "EnableBackgroundLogging", defaultValue: false)
    static var enableBackgroundLogging: Bool
    
    @CodableStorage(key: "BackgroundMode", defaultValue: nil, handler: _backgroundModeCallback)
    static var backgroundMode: BackgroundMode?
}

extension CodableColor {
    // MARK: - Color prefs
    @CodableStorage(key: "DefaultMessageEventColor", defaultValue: nil)
    static var defaultMessageEvent: CodableColor?
    
    @CodableStorage(key: "DebugMessageEventColor", defaultValue: CodableColor(uiColor: .systemOrange))
    static var debugMessageEvent: CodableColor
    
    @CodableStorage(key: "InfoMessageEventColor", defaultValue: nil)
    static var infoMessageEvent: CodableColor?
    
    @CodableStorage(key: "FaultMessageEventColor", defaultValue: CodableColor(uiColor: .systemRed))
    static var faultMessageEvent: CodableColor
    
    @CodableStorage(key: "ErrorMessageEventColor", defaultValue: CodableColor(uiColor: .systemRed))
    static var errorMessageEvent: CodableColor
}

fileprivate extension Preferences {
    // MARK: - Callbacks
    static func _timerIntervalCallback(newValue: Double) {
        NotificationCenter.default.post(
            Notification(name: .streamTimerIntervalDidChange, object: newValue)
        )
    }
    
    static func _backgroundModeCallback(key: String, newValue: BackgroundMode?) {
        ApplicationMonitor
            .shared
            .locationManager
            .locationManager
            .requestAlwaysAuthorization()
    }
    
    static func preferredLangChangedCallback(newValue: String?) {
        Bundle.preferredLocalizationBundle = .makeLocalizationBundle(preferredLanguageCode: newValue)
    }
}
