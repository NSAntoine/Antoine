//
//  StreamEvent.swift
//  Antoine
//
//  Created by Serena on 28/11/2022
//

import Foundation
import ActivityStreamBridge

enum StreamEvent: os_activity_stream_event_t {
    /// The stream has started
    case started = 1
    
    /// The stream has stopped
    case stopped = 2
    
    /// The stream has failed
    case failed = 3
    
    /// A chunk of events has started
    case chunkStarted = 4
    
    /// A chunk of events has ended
    case chunkFinished = 5
}
