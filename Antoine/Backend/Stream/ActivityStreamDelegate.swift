//
//  ActivityStreamDelegate.swift
//  Antoine
//
//  Created by Serena on 03/12/2022
//

import Foundation
import ActivityStreamBridge

protocol ActivityStreamDelegate: AnyObject {
    /// A new entry from the log was recieved
    func activityStream(didRecieveEntry entryPointer: os_activity_stream_entry_t, error: CInt)
    func activityStream(streamEventDidChangeTo newEvent: StreamEvent?)
}
