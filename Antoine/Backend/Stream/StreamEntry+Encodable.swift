//
//  StreamEntry+Codable.swift
//  Antoine
//
//  Created by Serena on 02/12/2022
//

import Foundation

extension StreamEntry: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(parentActivityID, forKey: .parentActivityID)
        try container.encode(activityID, forKey: .activityID)
        try container.encode(threadID, forKey: .threadID)
        try container.encode(traceID, forKey: .traceID)
        
        try container.encode(eventMessage, forKey: .eventMessage)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(messageType, forKey: .messageType)
        try container.encode(type?.displayText, forKey: .messageTypeDescription)
        
        try container.encode(persisted, forKey: .persisted)
        
        try container.encode(process, forKey: .process)
        try container.encode(processID, forKey: .processID)
        try container.encode(processImagePath, forKey: .processImagePath)
        try container.encode(processImageUUID, forKey: .processImageUUID)
        try container.encode(processUniqueID, forKey: .processUniqueID)
        
        try container.encode(sender, forKey: .sender)
        try container.encode(senderImagePath, forKey: .senderImagePath)
        try container.encode(senderImageUUID, forKey: .senderImageUUID)
        try container.encode(senderProgramCounter, forKey: .senderProgramCounter)
        
        try container.encode(timeGMT, forKey: .timeGMT)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(machTimestamp, forKey: .machTimestamp)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(timezoneName, forKey: .timezoneName)
        try container.encode(tz, forKey: .tz)
        
        try container.encode(category, forKey: .category)
        try container.encode(subsystem, forKey: .subsystem)
    }
    
    enum CodingKeys: CodingKey {
        case activityID, parentActivityID
        case eventMessage, eventType
        case machTimestamp
        case persisted
        case process
        case processID
        case processImagePath, processImageUUID, processUniqueID
        case sender, senderImagePath, senderImageUUID
        case threadID
        case timeGMT
        case timestamp
        case timezone, timezoneName
        case traceID
        case tz
        case category, subsystem
        case messageType, messageTypeDescription
        case senderProgramCounter
    }
}

extension timeval: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tv_sec, forKey: .tv_sec)
        try container.encode(tv_usec, forKey: .tv_usec)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tvSec = try container.decode(__darwin_time_t.self, forKey: .tv_sec)
        let tvUsec = try container.decode(__darwin_suseconds_t.self, forKey: .tv_usec)
        self.init(tv_sec: tvSec, tv_usec: tvUsec)
    }
    
    enum CodingKeys: CodingKey {
        case tv_sec, tv_usec
    }
}

extension timezone: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tz_minuteswest, forKey: .tz_minuteswest)
        try container.encode(tz_dsttime, forKey: .tz_dsttime)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            tz_minuteswest: try container.decode(Int32.self, forKey: .tz_minuteswest),
            tz_dsttime: try container.decode(Int32.self, forKey: .tz_dsttime)
        )
    }
    
    enum CodingKeys: CodingKey {
        case tz_minuteswest, tz_dsttime
    }
}
