//
//  MessageEvent.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import UIKit

/// A structure representing the type of a ``ActivityEvent`` log message,
/// such as ``default``, ``fault``, and ``debug``.
/// see -[OSActivityLogMessageEvent messageType].
struct MessageEvent: Hashable, CustomStringConvertible {
    let displayText: String
    var displayColor: UIColor?
    let rawValue: UInt8
    
    private init(displayText: String, color: UIColor?, rawValue: UInt8) {
        self.displayText = displayText
        self.displayColor = color
        self.rawValue = rawValue
    }
    
    private init(displayText: String, codableColor: CodableColor?, rawValue: UInt8) {
        self.displayText = displayText
        self.displayColor = codableColor?.uiColor
        self.rawValue = rawValue
    }
    
    init?(_ cLogType: UInt8) {
        switch cLogType {
        case 0x00:
            self = .default
        case 0x01:
            self = .info
        case 0x2:
            self = .debug
        case 0x10:
            self = .error
        case 0x11:
            self = .fault
        default:
            return nil
        }
    }
    
    var description: String {
        displayText
    }
    
    enum CodingKeys: CodingKey {
        case displayText
        case color
        case rawValue
    }
    
    static func == (lhs: MessageEvent, rhs: MessageEvent) -> Bool {
        // TODO: - This is probably bad but it works /shrug
        return lhs.displayText == rhs.displayText && lhs.rawValue == rhs.rawValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayText)
        hasher.combine(rawValue)
    }
}

extension MessageEvent: CaseIterable {
    // MARK: - Log types
    static var `default` = MessageEvent(displayText: .localized("Default"),
                                        codableColor: .defaultMessageEvent,
                                        rawValue: 0x00)
    
    static var debug =     MessageEvent(displayText: .localized("Debug"),
                                        codableColor: .debugMessageEvent,
                                        rawValue: 0x01)
    
    static var info =      MessageEvent(displayText: .localized("Info"),
                                        codableColor: .infoMessageEvent,
                                        rawValue: 0x2)
    
    static var fault =     MessageEvent(displayText: .localized("Fault"),
                                        codableColor: .faultMessageEvent,
                                        rawValue: 0x10)
    
    static var error =     MessageEvent(displayText: .localized("Error"),
                                        codableColor: .errorMessageEvent,
                                        rawValue: 0x11)
    /// `allCases` can be a ``let`` constant initialized once
    /// because the actual list of item doesn't change,
    /// however, we use ``allCasesNonLazily`` for contexts when the items themselves change,
    /// ie, when reloading PreferencesViewController.
    static var allCasesNonLazily: [MessageEvent] {
        return [.default, .info, .debug, .fault, .error]
    }
    
    static let allCases: [MessageEvent] = allCasesNonLazily
}

extension MessageEvent: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayText, forKey: .displayText)
        try container.encode(rawValue, forKey: .rawValue)
        
        if let color = displayColor {
            try container.encode(CodableColor(uiColor: color), forKey: .color)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayText = try container.decode(String.self, forKey: .displayText)
        self.rawValue = try container.decode(UInt8.self, forKey: .rawValue)
        self.displayColor = (try? container.decode(CodableColor.self, forKey: .color))?.uiColor
    }
}
