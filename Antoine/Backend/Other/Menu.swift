//
//  Menu.swift
//  Antoine
//
//  Created by Serena on 05/12/2022
//

import UIKit

class MenuItem {
    class func makeMenu(title: String = "", for items: [MenuItem]) -> UIMenu {
        var actions: [UIMenuElement] = []
        for item in items {
            if !item.embeddedItems.isEmpty {
                let uiActions =  item.embeddedItems.map(\.uiAction)
                actions.append(UIMenu(options: .displayInline, children: uiActions))
            } else {
                actions.append(item.uiAction)
            }
        }
        
        return UIMenu(title: title, children: actions)
    }
    
    class func setup(
        items: [MenuItem],
        forButton button: UIButton,
        alertControllerAction: @escaping (UIAlertController) -> Void
    ) {
        if #available(iOS 14.0, *) {
            let menu = makeMenu(for: items)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        } else {
            button.addAction(for: .touchUpInside) {
                // this may seem bad (and it is in code)
                // but it's what's needed in order to support embedded menus for iOS 14+..
                let actions = (items + items.flatMap(\.embeddedItems)).map { item in
                    return item.embeddedItems.isEmpty ? item.uiAlertAction : nil
                }
                    .compactMap { $0 }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                for action in actions {
                    alertController.addAction(action)
                }
                alertController.addAction(UIAlertAction(title: .localized("Cancel"), style: .cancel))
                
                alertControllerAction(alertController)
            }
        }
    }
    
    let title: String
    let image: UIImage?
    let isEnabled: Bool
    var embeddedItems: [MenuItem] = []
    let action: () -> Void
    
    init(title: String, image: UIImage?, isEnabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
    }
    
    init(items: [MenuItem]) {
        //TODO: - Better way to do this?
        self.title = ""
        self.image = nil
        self.embeddedItems = items
        self.isEnabled = false
        self.action = {}
    }
    
    var uiAction: UIAction {
        UIAction(title: title, image: image, state: isEnabled ? .on : .off) { _ in self.action() }
    }
    
    var uiAlertAction: UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { _ in
            self.action()
        }
        
        action.setValue(isEnabled, forKey: "checked")
        action.setValue(image, forKey: "image")
        return action
    }
}
