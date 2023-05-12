//
//  CodableEntry.swift
//  Antoine
//
//  Created by Serena on 11/05/2023.
//  

import Foundation
import ActivityStreamBridge

/// An entry which can be encoded & later decoded.
struct CodableEntry: Codable, Entry {
    var activityID: UInt
    var eventMessage: String
    var eventType: UInt
    var machTimestamp: UInt
    var parentActivityID: UInt
    var persisted: Bool
    var process: String
    var processID: Int32
    var processImagePath: String
    var processImageUUID: UUID
    var processUniqueID: UInt
    var sender: String
    var senderImagePath: String
    var threadID: UInt
    var timestamp: Date
    var entryTraceID: UInt
    var category: String?
    var messageType: UInt8
    var subsystem: String?
    var type: MessageEvent?
    
    init(streamEntry: any Entry) {
        self.activityID = streamEntry.activityID
        self.eventMessage = streamEntry.eventMessage
        self.eventType = streamEntry.eventType
        self.machTimestamp = streamEntry.machTimestamp
        self.parentActivityID = streamEntry.parentActivityID
        self.persisted = streamEntry.persisted
        self.process = streamEntry.process
        self.processID = streamEntry.processID
        self.processImagePath = streamEntry.processImagePath
        self.processImageUUID = streamEntry.processImageUUID
        self.processUniqueID = streamEntry.processUniqueID
        self.sender = streamEntry.sender
        self.senderImagePath = streamEntry.senderImagePath
        self.threadID = streamEntry.threadID
//        self.timeGMT = streamEntry.timeGMT
        self.timestamp = streamEntry.timestamp
        self.entryTraceID = streamEntry.entryTraceID
        self.category = streamEntry.category
        self.messageType = streamEntry.messageType
        self.subsystem = streamEntry.subsystem
        self.type = streamEntry.type
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
