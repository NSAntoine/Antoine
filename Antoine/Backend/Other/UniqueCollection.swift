//
//  UniqueCollection.swift
//  Antoine
//
//  Created by Serena on 03/01/2023
//

import Foundation

/// Describes a Unique Collection with methods to:
/// Check for the existance of a certain element,
/// Remove a certain element,
/// Insert a certain element
protocol UniqueCollection {
    associatedtype Element
    
    func contains(_ member: Element) -> Bool
    
    @discardableResult mutating func remove(_ member: Element) -> Element?
    @discardableResult mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
}

extension UniqueCollection {
    /// If the given element exists in the collection, remove it,
    /// otherwise, add it to the collection
    mutating func removeOrInsertBasedOnExistance(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

extension Set: UniqueCollection {}
// Add all `OptionSet` conforming types here
// since we can't do `extension OptionSet: UniqueCollection`
extension StreamOption: UniqueCollection {}

