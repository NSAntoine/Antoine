//
//  TextViewDelegate.swift
//  Antoine
//
//  Created by Serena on 15/12/2022
//

import UIKit

extension EntryFilterViewController: UITextViewDelegate {
    enum TextViewType: Int {
        case message = 1 // 0 is the default of -[UIView tag], so we start with 1
        case process
        case category
        case subsystem
        
        var placeholder: String {
            switch self {
            case .message:
                return .localized("Message text filter..")
            case .process:
                return .localized("Process name filter..")
            case .category:
                return .localized("Category filter..")
            case .subsystem:
                return .localized("Subsystem filter..")
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
        
        // scroll to the section of the textView
        var sectionToScrollTo: Section
        if let type = TextViewType(rawValue: textView.tag) {
            switch type {
            case .process:
                sectionToScrollTo = .processName
            case .message:
                sectionToScrollTo = .message
            case .category:
                sectionToScrollTo = .category
            case .subsystem:
                sectionToScrollTo = .subsystem
            }
            
            if let section = dataSource.snapshot().indexOfSection(sectionToScrollTo) {
                tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let type = TextViewType(rawValue: textView.tag) else { return }
        
        switch type {
        case .message:
            let newFilter = TextFilter(text: textView.text,
                                       mode: filter?.messageTextFilter?.mode ?? .contains)
            filter?.messageTextFilter = newFilter
        case .process:
            let newFilter = TextFilter(text: textView.text,
                                       mode: filter?.processFilter?.mode ?? .contains)
            filter?.processFilter = newFilter
        case .category:
            let newFilter = TextFilter(text: textView.text,
                                       mode: filter?.categoryFilter?.mode ?? .contains)
            filter?.categoryFilter = newFilter
        case .subsystem:
            let newFilter = TextFilter(text: textView.text,
                                       mode: filter?.subsystemFilter?.mode ?? .contains)
            filter?.subsystemFilter = newFilter
        }
        
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = type.placeholder
        }
    }
}
