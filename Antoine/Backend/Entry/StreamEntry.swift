//
//  StreamEntry.swift
//  Antoine
//
//  Created by Serena on 02/12/2022
//

import Foundation
import ActivityStreamBridge

/// A subclass of OSActivityLogMessageEvent, describing a basic activity event
/// suitable to display in UI
class StreamEntry: OSActivityLogMessageEvent, Entry {
    var type: MessageEvent?
    
    override init(entry: os_activity_stream_entry_t) {
        super.init(entry: entry)
        
        self.type = MessageEvent(self.messageType)
    }
    
    var entryTraceID: UInt {
        traceID // from OSActivityLogMessageEvent
    }
}
