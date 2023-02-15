//
//  EntryFilter.swift
//  Antoine
//
//  Created by Serena on 09/12/2022
//

import Foundation

#warning("Add support for making it so that it checks if the entry passes just one of those conditions, rather than all")
/// A Structure defining the filters that can be used to filter out unwanted entries by the user
struct EntryFilter: Codable, Hashable {
    public var messageTextFilter: TextFilter?
    public var processFilter: TextFilter?
    public var subsystemFilter: TextFilter?
    public var categoryFilter: TextFilter?
    public var pid: pid_t?
	
    /// for performance reasons,
    /// (not calling map to the rawValue every single time ``entryPassesFilter(_:)`` is called)
    /// this is a private var which is used in the ``entryPassesFilter(_:)`` function.
    private var _acceptedTypesInternal: [UInt8] = MessageEvent.allCases.map(\.rawValue)
    
    public var acceptedTypes: Set<MessageEvent> {
        didSet {
            _acceptedTypesInternal = acceptedTypes.map(\.rawValue)
        }
    }
    
    init(messageTextFilter: TextFilter? = nil,
         processFilter: TextFilter? = nil,
         subsystemFilter: TextFilter? = nil,
         categoryFilter: TextFilter? = nil,
         pid: pid_t? = nil) {
        
        self.messageTextFilter = messageTextFilter
        self.processFilter = processFilter
        self.subsystemFilter = subsystemFilter
        self.categoryFilter = categoryFilter
        self.pid = pid
        
        self.acceptedTypes = Set(_acceptedTypesInternal.compactMap(MessageEvent.init))
    }
    
    /// Check if a given entry passes the current filter
    public func entryPassesFilter(_ entry: StreamEntry) -> Bool {
        return (messageTextFilter?.matches(entry.eventMessage) ?? true)
        && (subsystemFilter?.matches(entry.subsystem) ?? true)
        && (categoryFilter?.matches(entry.category) ?? true)
        && (processFilter?.matches(entry.process) ?? true)
        && _acceptedTypesInternal.contains(entry.messageType)
        && isPidEqualTo(entry.processID)
    }
    
    // if pid is nil, then it'll be considered true in entryPassesFilter anyways
    private func isPidEqualTo(_ otherPid: pid_t) -> Bool {
        return pid == nil ? true : pid == otherPid
    }
}
