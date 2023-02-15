//
//  StreamEntryType.swift
//  Antoine
//
//  Created by Serena on 03/12/2022
//

import ActivityStreamBridge

enum StreamEntryType: os_activity_stream_type_t, CustomStringConvertible {
    case activityCreate = 0x0201
    case activityTransition = 0x0202
    case activityUserAction = 0x0203
    
    case traceMessage = 0x0300
    
    case logMessage = 0x0400
    case legacyLogMessage = 0x0480
    
    case signpostBegin = 0x0601
    case signpostEnd = 0x0602
    case signpostEvent = 0x0603
    
    case statedumpEvent = 0x0A00
    
    // Don't think we should localize these
    var description: String {
        switch self {
        case .activityCreate:
            return "Activity (Create)"
        case .activityTransition:
            return "Activity (Transition)"
        case .activityUserAction:
            return "Activity (User Action)"
        case .traceMessage:
            return "Trace Message"
        case .logMessage:
            return "Log Message"
        case .legacyLogMessage:
            return "Log Message (Legacy)"
        case .signpostBegin:
            return "Signpost Begin"
        case .signpostEnd:
            return "Signpost End"
        case .signpostEvent:
            return "Signpost Event"
        case .statedumpEvent:
            return "Statedump Event"
        }
    }
}
