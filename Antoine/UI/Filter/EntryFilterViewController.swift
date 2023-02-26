//
//  EntryFilterViewController.swift
//  Antoine
//
//  Created by Serena on 09/12/2022
//
//  WARNING: Ugly, disastrous code ahead.
//  Seriously, this is the worst file in the entire project.

import UIKit

/// A View Controller to control the filters of which entries to show in StreamViewController
class EntryFilterViewController: UIViewController {
    /// The filter to control and maniplunate,
    /// note: if this filter is nil, that means the user has decided to not use a filter
    var filter: EntryFilter?
    
    
    weak var delegate: EntryFilterViewControllerDelegate?
    
    lazy var applyButton = UIButton(type: .system)
    
    init(filter: EntryFilter? = Preferences.entryFilter) {
        self.filter = filter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = itemIdentifier.labelText
        itemIdentifier.handler?(cell)
        return cell
    }
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.shadowImage = nil
        
        navigationItem.title = .localized("Search Filter")
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
        
        // Disable swipe-to-dismiss
        isModalInPresentation = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Preferences.entryFilter = filter
        delegate?.didFinishEditing(self)
    }
    
    // layout the table view
    func setupViews() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.constraintCompletely(to: view)
        
        addInitialItem()
        dataSource.defaultRowAnimation = .fade
        
        applyButton.backgroundColor = view.tintColor
        applyButton.setTitle(.localized("Apply"), for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.shadowOpacity = 0.4
        applyButton.layer.cornerRadius = 20
        applyButton.layer.cornerCurve = .circular
        applyButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(applyButton)
        NSLayoutConstraint.activate([
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            applyButton.widthAnchor.constraint(equalToConstant: 120.5),
            applyButton.heightAnchor.constraint(equalToConstant: 40.3)
        ])
        view.addSubview(applyButton)
    }
    
    deinit {
        NSLog("EntryFilterViewController deinitializer called, we're all clear.")
    }
    
    @objc func dismissAction() {
        dismiss(animated: true)
    }
}

extension EntryFilterViewController {
    // MARK: - meths to add items to the data source
    
    /// adds initial item, being just the "Enabled" checkmark if there isn't already a filter set
    func addInitialItem() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let enabledAction = Item(labelText: .localized("Enabled"), id: "FilterEnabled") { [unowned self] cell in
            let uiSwitch = UISwitch()
            uiSwitch.isOn = self.filter != nil
            uiSwitch.addTarget(self, action: #selector(self.isEnabledDidChange(sender:)), for: .valueChanged)
            cell.accessoryView = uiSwitch
        }
        
        snapshot.appendSections([.isEnabled])
        snapshot.appendItems([enabledAction], toSection: .isEnabled)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if filter != nil { addRestOfItems() }
    }
    
    /// adds rest of the items
    func addRestOfItems() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.sections, .allowedTypes])
        
        var sectionsAndItemsToAdd: [(section: Section, items: [Item])] = []
        
        if filter?.messageTextFilter != nil {
            sectionsAndItemsToAdd.append((.message, makeMessageFilterSectionItems()))
        }
        
        if filter?.pid != nil {
            sectionsAndItemsToAdd.append((.processID, makeProcessIDFilterSectionItems()))
        }
        
        if filter?.processFilter != nil {
            sectionsAndItemsToAdd.append((.processName,  makeProcessNameFilterSectionItems()))
        }
        
        if filter?.categoryFilter != nil {
            sectionsAndItemsToAdd.append((.category, makeCategorySectionItems()))
        }
        
        if filter?.subsystemFilter != nil {
            sectionsAndItemsToAdd.append((.subsystem, makeSubsystemSectionItems()))
        }
        
        let justSections = sectionsAndItemsToAdd.map(\.section)
        snapshot.insertSections(justSections, beforeSection: .allowedTypes)
        
        for (section, items) in sectionsAndItemsToAdd {
            snapshot.appendItems(items, toSection: section)
        }
        
        snapshot.appendItems(makeRestOfisEnabledSectionItems(), toSection: .sections)
        snapshot.appendItems(makeAllowedTypesSectionItem(), toSection: .allowedTypes)
        
        dataSource.apply(snapshot)
    }
    
    @objc
    func isEnabledDidChange(sender: UISwitch) {
        if sender.isOn {
            filter = Preferences.entryFilter ?? EntryFilter()
            Preferences.entryFilter = filter
            addRestOfItems()
        } else {
            filter = nil
            addInitialItem()
        }
        
    }
}

extension EntryFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false // man fuck you
    }
}

private extension EntryFilterViewController {
    // MARK: - Methods to create section items
    
    // In case you're confused, this exists in order to simplify the code when a section toggle
    // (such as "Filter by message text")
    // is turned on/off, the usage of key paths here is necessary for this function to exist
    func sectionToggleClicked<Property>(uiSwitch: UISwitch,
                                        section: Section,
                                        writablePath: WritableKeyPath<EntryFilter, Property?>,
                                        newPropertyBuilder: @autoclosure () -> Property?,
                                        sectionRebuilder: () -> [Item]) {
        var snapshot = dataSource.snapshot()
        if uiSwitch.isOn {
            filter?[keyPath: writablePath] = newPropertyBuilder()
            // allowedTypes is always last
            snapshot.insertSections([section], beforeSection: .allowedTypes)
            snapshot.appendItems(sectionRebuilder(), toSection: section)
        } else {
            filter?[keyPath: writablePath] = nil
            snapshot.deleteSections([section])
        }
        
        dataSource.apply(snapshot)
    }
    
    // makes the rest of the "is enabled" section items
    // ie, "Filter by message", to enable filtering by message
    func makeRestOfisEnabledSectionItems() -> [Item] {
        let filterByMessage = __makeIsEnabledItemWithSwitch(
            name: .localized("Filter by Message Text"),
            id: "TextMessageFilteringEnabled") { [unowned self] uiSwitch in
                uiSwitch.isOn = filter?.messageTextFilter != nil
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    sectionToggleClicked(uiSwitch: uiSwitch,
                                         section: .message,
                                         writablePath: \.messageTextFilter,
                                         newPropertyBuilder: TextFilter.empty,
                                         sectionRebuilder: makeMessageFilterSectionItems)
                    
                }
            }
        
        let filterByPID = __makeIsEnabledItemWithSwitch(
            name: .localized("Filter by Process ID"),
            id: "FilterByProcessIDEnabled") { uiSwitch in
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    sectionToggleClicked(uiSwitch: uiSwitch,
                                         section: .processID,
                                         writablePath: \.pid,
                                         newPropertyBuilder: nil,
                                         sectionRebuilder: makeProcessIDFilterSectionItems)
                }
            }
        
        let filterByProcessName = __makeIsEnabledItemWithSwitch(
            name: .localized("Filter by Process Name"),
            id: "FilterByProcessNameEnabled") { [unowned self] uiSwitch in
                uiSwitch.isOn = filter?.processFilter != nil
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    sectionToggleClicked(uiSwitch: uiSwitch,
                                         section: .processName,
                                         writablePath: \.processFilter,
                                         newPropertyBuilder: TextFilter.empty,
                                         sectionRebuilder: makeProcessNameFilterSectionItems)
                }
                
            }
        
        let filterByCategory = __makeIsEnabledItemWithSwitch(
            name: .localized("Filter by Category"),
            id: "FilterByCategory") { [unowned self] uiSwitch in
                uiSwitch.isOn = filter?.categoryFilter != nil
                
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    sectionToggleClicked(uiSwitch: uiSwitch,
                                         section: .category,
                                         writablePath: \.categoryFilter,
                                         newPropertyBuilder: TextFilter.empty,
                                         sectionRebuilder: makeCategorySectionItems)
                }
            }
        
        
        let filterBySubsystem = __makeIsEnabledItemWithSwitch(
            name: .localized("Filter by Subsystem"),
            id: "FilterBySubsystem") { [unowned self] uiSwitch in
                uiSwitch.isOn = filter?.subsystemFilter != nil
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    sectionToggleClicked(uiSwitch: uiSwitch,
                                         section: .subsystem,
                                         writablePath: \.subsystemFilter,
                                         newPropertyBuilder: TextFilter.empty,
                                         sectionRebuilder: makeSubsystemSectionItems)
                }
            }
        
        return [filterByMessage, filterByProcessName, filterByCategory, filterBySubsystem, filterByPID]
    }
    
    // makes the items under the "Message" section
    func makeMessageFilterSectionItems() -> [Item] {
        guard let messageTextFilter = filter?.messageTextFilter else {
            return []
        }
        
        return makeTextViewAndModeSection(textView: _makeGenericTextView(for: .message, text: messageTextFilter.text), toEdit: messageTextFilter) { [unowned self] newMode in
            let newFilter = TextFilter(text: filter?.messageTextFilter?.text ?? "", mode: newMode)
            newModeSelected(section: .message, sectionRebuilder: makeMessageFilterSectionItems, writableKeyPath: \.messageTextFilter, newItem: newFilter)
        }
    }
    
    func newModeSelected<Property>(section: Section, sectionRebuilder: () -> [Item],
                                   writableKeyPath: WritableKeyPath<EntryFilter, Property?>,
                                   newItem: @autoclosure () -> Property?) {
        filter?[keyPath: writableKeyPath] = newItem()
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(inSection: section, rebuildWith: sectionRebuilder())
        dataSource.apply(snapshot)
    }
    
    func makeProcessIDFilterSectionItems() -> [Item] {
        let pidTextFieldItem = Item(labelText: .localized("Process ID"), id: "PIDTextField") { [unowned self] cell in
            let textField = _makeGenericTextField(text: filter?.pid?.description, placeholder: .localized("Process ID"))
            textField.addAction(for: .editingDidEnd) { [unowned self] in
                guard let text = textField.text, let newPid = pid_t(text) else {
                    errorAlert(title: .localized("Process ID entered must be a valid number"), description: nil)
                    textField.text = nil
                    return
                }
                
                filter?.pid = newPid
            }
            
            cell.contentView.addSubview(textField)
            
            NSLayoutConstraint.activate([
                textField.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
            ])
        }
        
        return [pidTextFieldItem]
    }
    
    func makeCategorySectionItems() -> [Item] {
        guard let categoryFilter = filter?.categoryFilter else {
            return []
        }
        
        return makeTextViewAndModeSection(textView: _makeGenericTextView(for: .category, text: categoryFilter.text), toEdit: categoryFilter) { [unowned self] newMode in
            let newFilter = TextFilter(text: filter?.categoryFilter?.text ?? "", mode: newMode)
            newModeSelected(section: .category,
                            sectionRebuilder: makeCategorySectionItems,
                            writableKeyPath: \.categoryFilter, newItem: newFilter)
            /*
             let existingText = filter?.categoryFilter?.text ?? ""
             filter?.categoryFilter = TextFilter(text: existingText, mode: newMode)
             
             var snapshot = dataSource.snapshot()
             snapshot.reloadItems(inSection: .category, rebuildWith: makeCategorySectionItems())
             dataSource.apply(snapshot)
             */
        }
    }
    
    func makeSubsystemSectionItems() -> [Item] {
        guard let subsystemFilter = filter?.subsystemFilter else {
            return []
        }
        
        return makeTextViewAndModeSection(textView: _makeGenericTextView(for: .subsystem, text: subsystemFilter.text), toEdit: subsystemFilter) { [unowned self] newMode in
            let newFilter = TextFilter(text: filter?.subsystemFilter?.text ?? "", mode: newMode)
            
            newModeSelected(section: .subsystem,
                            sectionRebuilder: makeSubsystemSectionItems,
                            writableKeyPath: \.subsystemFilter, newItem: newFilter)
        }
    }
    
    func makeProcessNameFilterSectionItems() -> [Item] {
        guard let processFilter = filter?.processFilter else {
            return []
        }
        
        return makeTextViewAndModeSection(textView: _makeGenericTextView(for: .process, text: processFilter.text), toEdit: processFilter) { [unowned self] newMode in
            let newFilter = TextFilter(text: filter?.processFilter?.text ?? "", mode: newMode)
            
            newModeSelected(section: .processName,
                            sectionRebuilder: makeProcessNameFilterSectionItems,
                            writableKeyPath: \.processFilter,
                            newItem: newFilter)
        }
    }
    
    func makeAllowedTypesSectionItem() -> [Item] {
        return MessageEvent.allCases.map { type in
            return Item(labelText: type.description, id: type.description) { [unowned self] cell in
                let uiSwitch = UISwitch()
                uiSwitch.isOn = self.filter?.acceptedTypes.contains(type) ?? false
                
                uiSwitch.addAction(for: .valueChanged) { [unowned self] in
                    filter?.acceptedTypes.removeOrInsertBasedOnExistance(type)
                }
                
                cell.accessoryView = uiSwitch
            }
        }
    }
    
    func __makeIsEnabledItemWithSwitch(name: String,
                                       id: String,
                                       handler: @escaping (UISwitch) -> Void) -> Item {
        let uiSwitch = UISwitch()
        handler(uiSwitch)
        return Item(labelText: name, id: id) { cell in
            if cell.accessoryView != uiSwitch {
                cell.accessoryView = uiSwitch
            }
        }
    }
    
    func makeTextViewAndModeSection(textView: UITextView,
                                    toEdit filterToEdit: TextFilter,
                                    newModeCompletion: @escaping (TextFilter.Mode) -> Void,
                                    senderFunction: String = #function) -> [Item] {
        let textViewItem = Item(labelText: nil, id: "\(senderFunction)TextView") { [unowned self] cell in
            __setupTextView(forCell: cell, textView: textView)
        }
        
        let modeItem = Item(labelText: .localized("Mode"), id: "\(senderFunction)=\(filterToEdit.mode)") { [unowned self] cell in
            let image = UIImage(systemName: "chevron.up.chevron.down")
            cell.addChoiceButton(text: filterToEdit.mode.description, image: image) { button in
                let items = __menuItemsForAllModes(selectedMode: filterToEdit.mode, handler: newModeCompletion)
                
                MenuItem.setup(items: items, forButton: button) { [unowned self] alert in
                    present(alert, animated: true)
                }
            }
        }
        return [textViewItem, modeItem]
    }
}

extension EntryFilterViewController {
    // MARK: - Creating commonly used views
    private func _makeGenericTextView(for type: TextViewType, text: String?) -> UITextView {
        let textView = UITextView()
        
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.tag = type.rawValue
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.textContainerInset = .zero
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        textView.inputAccessoryView = _makeToolbar(for: textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // placeholder text is empty
        if text?.isEmpty ?? true {
            textView.textColor = .lightGray
            textView.text = type.placeholder
        } else {
            textView.text = text
        }
        
        return textView
    }
    
    private func _makeGenericTextField(text: String?, placeholder: String?, type: UIKeyboardType = .numberPad) -> UITextField {
        let textField = UITextField()
        
        textField.text = text
        textField.placeholder = placeholder
        textField.inputAccessoryView = _makeToolbar(for: textField)
        textField.keyboardType = type
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func _makeToolbar(for responder: UIResponder) -> UIToolbar {
        let toolbar = UIToolbar()
        let doneButton = UIButton()
        doneButton.setTitleColor(view.tintColor, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        
        doneButton.addAction(for: .touchUpInside) {
            responder.resignFirstResponder()
        }
        
        let items = [
            // so that the done button is setup to the right
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            // the done button
            UIBarButtonItem(customView: doneButton)
        ]
        
        toolbar.setItems(items, animated: true)
        toolbar.sizeToFit()
        return toolbar
    }
    
    private func __menuItemsForAllModes(selectedMode: TextFilter.Mode,
                                        handler: @escaping (TextFilter.Mode) -> Void) -> [MenuItem] {
        return TextFilter.Mode.allCasesSectioned.map { modes in
            let items = modes.map { mode in
                return MenuItem(title: mode.description, image: nil, isEnabled: selectedMode == mode) {
                    handler(mode)
                }
            }
            
            return MenuItem(items: items)
        }
    }
    
    private func __setupTextView(forCell cell: UITableViewCell, textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(textView)
        
        let bottomAnchorConstraint = cell
            .contentView
            .layoutMarginsGuide
            .bottomAnchor.constraint(equalToSystemSpacingBelow: textView.lastBaselineAnchor, multiplier: 1)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: cell.layoutMarginsGuide.topAnchor),
            bottomAnchorConstraint
        ])
    }
}
