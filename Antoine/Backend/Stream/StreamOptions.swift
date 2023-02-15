//
//  LogStreamStartOptions.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import Foundation
import ActivityStreamBridge

struct StreamOptions: OptionSet {
    var rawValue: Int
    
    static let processOnly =       StreamOptions(rawValue: OS_ACTIVITY_STREAM_PROCESS_ONLY)
    static let skipDecode =        StreamOptions(rawValue: OS_ACTIVITY_STREAM_SKIP_DECODE)
    static let payload =           StreamOptions(rawValue: OS_ACTIVITY_STREAM_PAYLOAD)
    static let showHistorical =    StreamOptions(rawValue: OS_ACTIVITY_STREAM_HISTORICAL)
    static let showCallstack =     StreamOptions(rawValue: OS_ACTIVITY_STREAM_CALLSTACK)
    static let debug =             StreamOptions(rawValue: OS_ACTIVITY_STREAM_DEBUG)
    static let buffered =          StreamOptions(rawValue: OS_ACTIVITY_STREAM_BUFFERED)
    static let noSensitive =       StreamOptions(rawValue: OS_ACTIVITY_STREAM_NO_SENSITIVE)
    static let info =              StreamOptions(rawValue: OS_ACTIVITY_STREAM_INFO)
    static let promiscous =        StreamOptions(rawValue: OS_ACTIVITY_STREAM_PROMISCUOUS)
    static let preciseTimestamps = StreamOptions(rawValue: OS_ACTIVITY_STREAM_PRECISE_TIMESTAMPS)
    
    static let all: StreamOptions = [
        .processOnly,
        .skipDecode,
        .payload,
        .showHistorical,
        .showCallstack,
        .debug,
        .buffered,
        .noSensitive,
        .info,
        .promiscous,
        .preciseTimestamps
    ]
}

/// A Stream Option with a given title, to present in User Interface.
struct TitledStreamOption {
    static let all = [
        TitledStreamOption(title: .localized("All"), option: .all),
        TitledStreamOption(title: .localized("Show Messages before Stream was started"),
                           option: .showHistorical),
        TitledStreamOption(title: .localized("Don't include sensitive data"), option: .noSensitive),
        TitledStreamOption(title: .localized("Include Debug Messages"), option: .debug),
        TitledStreamOption(title: .localized("Include Info Messages"), option: .info),
        TitledStreamOption(title: .localized("Precise Timestamps"), option: .preciseTimestamps),
    ]
    
    let title: String
    let option: StreamOptions
}
