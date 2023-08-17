//
//  LogStreamStartOptions.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import Foundation
import ActivityStreamBridge

struct StreamOption: OptionSet {
    var rawValue: Int
    
    static let processOnly =       StreamOption(rawValue: OS_ACTIVITY_STREAM_PROCESS_ONLY)
    static let skipDecode =        StreamOption(rawValue: OS_ACTIVITY_STREAM_SKIP_DECODE)
    static let payload =           StreamOption(rawValue: OS_ACTIVITY_STREAM_PAYLOAD)
    static let showHistorical =    StreamOption(rawValue: OS_ACTIVITY_STREAM_HISTORICAL)
    static let showCallstack =     StreamOption(rawValue: OS_ACTIVITY_STREAM_CALLSTACK)
    static let debug =             StreamOption(rawValue: OS_ACTIVITY_STREAM_DEBUG)
    static let buffered =          StreamOption(rawValue: OS_ACTIVITY_STREAM_BUFFERED)
    static let info =              StreamOption(rawValue: OS_ACTIVITY_STREAM_INFO)
    static let promiscous =        StreamOption(rawValue: OS_ACTIVITY_STREAM_PROMISCUOUS)
    static let preciseTimestamps = StreamOption(rawValue: OS_ACTIVITY_STREAM_PRECISE_TIMESTAMPS)
}

/// A Stream Option with a given title, to present in User Interface.
struct TitledStreamOption {
    
    static let all = [
        TitledStreamOption(title: .localized("All"), option: [.showHistorical, .debug, .info, .preciseTimestamps]),
        TitledStreamOption(title: .localized("Show Messages before Stream was started"),
                           option: .showHistorical),
        TitledStreamOption(title: .localized("Include Debug Messages"), option: .debug),
        TitledStreamOption(title: .localized("Include Info Messages"), option: .info),
        TitledStreamOption(title: .localized("Precise Timestamps"), option: .preciseTimestamps),
    ]
    
    let title: String
    let option: StreamOption
}
