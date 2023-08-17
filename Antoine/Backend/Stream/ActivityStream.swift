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
    
    static func enableShowPrivateData(_ newStatus: Bool) {
        var ourCurrentDiagFlags: UInt32 = 0
        
        // Not going to cache this value as a `static let` because `enableShowPrivateData` is prob just gonna run
        // 1 or 2 times through the app's lifetime
        let privateDataFlag: UInt32 = 1 << 24
        
        host_get_atm_diagnostic_flag(mach_host_self(), &ourCurrentDiagFlags)
        
        let kret: kern_return_t
        
        if newStatus {
            kret = host_set_atm_diagnostic_flag(mach_host_self(), ourCurrentDiagFlags | privateDataFlag)
        } else {
            kret = host_set_atm_diagnostic_flag(mach_host_self(), ourCurrentDiagFlags & ~privateDataFlag)
        }
        
        if kret != KERN_SUCCESS {
            NSLog("\(#function): Failed to set private data flag to \(newStatus ? "enabled" : "disabled"), error: \(String(cString: mach_error_string(kret)))")
        } else {
            NSLog("\(#function): successful")
        }
    }
    
    /// Start the Log Stream.
    func start(options: StreamOption) {
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
