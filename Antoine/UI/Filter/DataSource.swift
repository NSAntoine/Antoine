//
//  EntryFilterControllerDataSource.swift
//  Antoine
//
//  Created by Serena on 10/12/2022
//

import UIKit

extension EntryFilterViewController {
    // MARK: - Types for the (Diffable) data source
    enum Section: Hashable, CaseIterable {
        case isEnabled
        case sections // the sections to enable/disable
        case message // filter by message text
        case processID // filter by processID
        case processName // filter by process name
        case subsystem // filter by subsystem
        case category // filter by category
        case allowedTypes // filter by allowed types (debug, error, fault, etc)
        
        var title: String? {
            switch self {
            case .isEnabled, .sections:
                return nil
            case .message:
                return .localized("Message")
            case .processID:
                return .localized("Process ID")
            case .processName:
                return .localized("Process Name")
            case .category:
                return .localized("Category")
            case .subsystem:
                return .localized("Subsystem")
            case .allowedTypes:
                return .localized("Allowed Types")
            }
        }
    }
    
    // MARK: - !!!!!! IMPORTANT NOTE !!!!!!
    /// Represents an item to display in a UITableViewCell
    /// Make sure to use `unowned self` in handler, otherwise YOU WILL have a retain cycle
    struct Item: Hashable {
        
        typealias Handler = (UITableViewCell) -> Void
        
        init(labelText: String?, id: String, handler: @escaping Handler) {
            self.labelText = labelText
            self.id = id
            self.handler = handler
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id
        }
        
        let labelText: String?
        let id: String
        var handler: Handler?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    // this subclass exists to be able to set header titles
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return snapshot().sectionIdentifiers[section].title
        }
    }
}
