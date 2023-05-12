//
//  Entry.swift
//  Antoine
//
//  Created by Serena on 11/05/2023.
//  

import Foundation

/// A Basic protocol describing an entry.
protocol Entry {
    var activityID: UInt { get }
    var eventMessage: String { get }
    var eventType: UInt { get }
    var machTimestamp: UInt { get }
    var parentActivityID: UInt { get }
    var persisted: Bool { get }
    var process: String { get }
    var processID: Int32 { get }
    var processImagePath: String { get }
    var processImageUUID: UUID { get }
    var processUniqueID: UInt { get }
    var sender: String { get }
    var senderImagePath: String { get }
    var threadID: UInt { get }
    var timestamp: Date { get }
    var entryTraceID: UInt { get }
    var category: String? { get }
    var messageType: UInt8 { get }
    var subsystem: String? { get }
    var type: MessageEvent? { get }
}
