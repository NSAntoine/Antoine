//
//  ActivityStream.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import Foundation
import ActivityStreamBridge

/// A type managing incoming log entires
class ActivityStream {
    
    private var activityStreamPtr: OpaquePointer? = nil
    
    weak var delegate: ActivityStreamDelegate?
    
    public init() {}
    
    var isStreaming: Bool = false
    
    /// Start the Log Stream.
    func start(options: StreamOptions) {
        let messageHandler: os_activity_stream_block_t = { (entry, error) in
            self.delegate?.activityStream(didRecieveEntry: entry, error: error)
            return true
        }
        
        let eventBlock: os_activity_stream_event_block_t = { stream, event in
            let streamEv = StreamEvent(rawValue: event)
            switch streamEv {
            case .started:
                self.isStreaming = true
            case .stopped, .failed:
                self.isStreaming = false
            default: break
            }
            
            self.delegate?.activityStream(streamEventDidChangeTo: streamEv)
        }
        
        let activityStream = OpaquePointer(os_activity_stream_for_pid(-1, os_activity_stream_flag_t(options.rawValue), messageHandler))
        
        self.activityStreamPtr = activityStream
        os_activity_stream_set_event_handler(activityStream, eventBlock)
        os_activity_stream_resume(activityStream)
    }
    
    /// Cancel the log stream, if one is in work
    func cancel() {
        if let activityStream = activityStreamPtr {
            os_activity_stream_cancel(activityStream)
            self.activityStreamPtr = nil
        }
    }
    
}
