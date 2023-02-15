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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let type = TextViewType(rawValue: textView.tag) else { return }
        
        switch type {
        case .message:
            filter?.messageTextFilter?.text = textView.text
        case .process:
            filter?.processFilter?.text = textView.text
        case .category:
            filter?.categoryFilter?.text = textView.text
        case .subsystem:
            filter?.subsystemFilter?.text = textView.text
        }
        
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = type.placeholder
        }
    }
}
