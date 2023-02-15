//
//  EntryViewController.swift
//  Antoine
//
//  Created by Serena on 29/11/2022
//

import UIKit
import ActivityStreamBridge

/// A View Controller displaying information about an entry,
/// including it's metadata and it's text.
class EntryViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, DetailItem>
    var tableView: UITableView!
    var titleView: UIView!
    var textView: UITextView!
    
    var entry: StreamEntry
    
    lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if #available(iOS 14.0, *) {
            var conf = cell.defaultContentConfiguration()
            conf.text = itemIdentifier.primaryText
            conf.secondaryText = itemIdentifier.secondaryText
            cell.contentConfiguration = conf
		} else {
            cell.textLabel?.text = itemIdentifier.primaryText
            cell.detailTextLabel?.text = itemIdentifier.secondaryText
        }
        
        itemIdentifier.handler?(cell)
        return cell
    }
    
    init(entry: StreamEntry) {
        self.entry = entry
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
		
        setupTitleView()
        setupTableView()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if #available(iOS 15, *) {
            // in viewDidLoad, view.window is nil,
            // so we set it here in viewDidAppear(_:) instead
			view.window?.windowScene?.title = "Entry - \(entry.process)"
		}
	}
    
    func setupTitleView() {
        self.titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = entry.type?.displayColor ?? view.tintColor
        
        view.addSubview(titleView)
        
        let processLabel = UILabel(text: entry.process,
                                   font: .monospacedSystemFont(ofSize: 30, weight: .bold),
                                   textColor: .white)
        processLabel.adjustsFontSizeToFitWidth = true
        
        var moreDetailsText = DateFormatter(dateFormat: "MMM d, h:mm a").string(from: entry.timestamp)
        // the label underneath the large process title
        if let type = entry.type {
            moreDetailsText.append("- \(type.description)")
        }
        
        let moreDetailsLabel = UILabel(text: moreDetailsText, font: .preferredFont(forTextStyle: .footnote), textColor: .white)
        
        let labelsStackView = UIStackView(arrangedSubviews: [processLabel, moreDetailsLabel])
        labelsStackView.axis = .vertical
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(labelsStackView)
        
        view.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: view.bounds.height / 6.8),
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            
            labelsStackView.leadingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.leadingAnchor, constant: 17),
            
            labelsStackView.trailingAnchor.constraint(equalTo: titleView.layoutMarginsGuide.trailingAnchor),
            labelsStackView.centerYAnchor.constraint(equalTo: titleView.layoutMarginsGuide.centerYAnchor)
        ])
    }
    
    
    func setupTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 6.8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        dataSource.defaultRowAnimation = .fade
        addItems()
        
        if splitViewController != nil {
            tableView.backgroundColor = .tertiarySystemGroupedBackground
        }
    }
    
    func addItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DetailItem>()
        
        for section in Section.allCases {
            snapshot.appendSections([section])
            snapshot.appendItems(detailItems(section: section), toSection: section)
        }
        
        dataSource.apply(snapshot)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section, indexPath.row) == (0, 0) {
            return 200
        }
        
        return UITableView.automaticDimension
    }
    
    func detailItems(section: Section) -> [DetailItem] {
        switch section {
        case .message:
            let messageItem = DetailItem(primaryText: nil, secondaryText: nil, id: "Message") { [unowned self] cell in
                if textView == nil {
                    self.textView = UITextView()
                    textView.isEditable = false
                    textView.textColor = .label
                    textView.font = .monospacedSystemFont(ofSize: 15, weight: .semibold)
                    textView.translatesAutoresizingMaskIntoConstraints = false
                    textView.text = entry.eventMessage
                    textView.sizeToFit()
                    textView.backgroundColor = .secondarySystemGroupedBackground
                } else {
                    textView.removeFromSuperview()
                }
                
                textView.layer.cornerRadius = 10
                
                let container = UIView()
                container.addSubview(textView)
                
                NSLayoutConstraint.activate([
                    textView.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
                    textView.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
                    textView.topAnchor.constraint(equalTo: container.topAnchor),
                    textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
                ])
                
                container.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(container)
                container.constraintCompletely(to: cell.contentView)
            }
            
            return [messageItem]
        case .process:
            return [
				DetailItem(primaryText: .localized("Name"),
						   secondaryText: entry.process, id: "ProcessName"),
				DetailItem(primaryText: .localized("ID"),
						   secondaryText: entry.processID, id: "ProcessID"),
				DetailItem(primaryText: .localized("Path"),
						   secondaryText: entry.processImagePath, id: "ProcessPath")
            ]
        case .sender:
            return [
				DetailItem(primaryText: .localized("Name"),
						   secondaryText: entry.sender, id: "SenderName"),
				DetailItem(primaryText: .localized("Path"),
						   secondaryText: entry.senderImagePath, id: "SenderPath")
            ]
        case .date:
            let dateFormatter = DateFormatter(dateFormat: "MMM d, h:mm a")
            return [
				DetailItem(primaryText: .localized("Date"),
						   secondaryText: dateFormatter.string(from: entry.timestamp),
						   id: "FormattedDate"),
				DetailItem(primaryText: .localized("Timestamp (UNIX Time)"),
						   secondaryText: Int(entry.timestamp.timeIntervalSince1970),
						   id: "UNIXTimeStamp")
            ]
        case .categoryAndSubsystem:
            return [
				DetailItem(primaryText: .localized("Category"),
						   secondaryText: entry.category ?? "Unknown", id: "Category"),
				DetailItem(primaryText: .localized("Subsystem"),
						   secondaryText: entry.subsystem ?? "Unknown", id: "Subsystem")
            ]
        case .other:
			let eventType = StreamEntryType(rawValue: UInt32(entry.eventType))
            return [
				DetailItem(primaryText: .localized("Message Type"), secondaryText: entry.type?.displayText ?? "Unknown", id: "MessageType"),
				DetailItem(primaryText: .localized("Event Type"),
						   secondaryText: eventType?.description ?? "Unknown",
						   id: "EventType"),
				DetailItem(primaryText: .localized("Activity ID"),
						   secondaryText: entry.activityID, id: "ActivityID"),
				DetailItem(primaryText: .localized("Trace ID"),
						   secondaryText: entry.traceID, id: "TraceID"),
				DetailItem(primaryText: .localized("Thread ID"),
						   secondaryText: entry.threadID, id: "ThreadID")
            ]
        }
    }
    
    deinit {
        print("EntryViewController deinit called for \(entry)")
    }
}

extension EntryViewController {
    enum Section: CaseIterable {
        case message
        case process
        case sender
        case date
        case categoryAndSubsystem
        case other
        
        var title: String {
            switch self {
            case .message:
                return .localized("Message")
            case .process:
                return .localized("Process")
            case .sender:
                return .localized("Sender")
            case .date:
                return .localized("Date")
            case .categoryAndSubsystem:
                return .localized("Category & Subsystem")
            case .other:
                return .localized("Other")
            }
        }
    }
    
    struct DetailItem: Hashable {
        typealias Handler = (UITableViewCell) -> Void
        
        static func == (lhs: EntryViewController.DetailItem, rhs: EntryViewController.DetailItem) -> Bool {
            return lhs.id == rhs.id
        }
        
        let primaryText: String?
        let secondaryText: String?
        let handler: Handler?
        let id: String
        
        init(primaryText: String?, secondaryText: String?, id: String, handler: Handler? = nil) {
            self.primaryText = primaryText
            self.secondaryText = secondaryText
            self.handler = handler
            self.id = id
        }
        
        init<Descriptive: CustomStringConvertible>(primaryText: String?,
                                                   secondaryText: Descriptive?,
                                                   id: String,
                                                   handler: Handler? = nil) {
            self.primaryText = primaryText
            self.secondaryText = secondaryText?.description
            self.handler = handler
            self.id = id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

extension EntryViewController: UITableViewDelegate {
    static let headerLabelFont: UIFont = .boldSystemFont(ofSize: 20)
    
    // iOS 13 support for collapsing sections:
    // can only really add built-in collapsible sections in iOS 14... :(
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionNumber: Int) -> UIView? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[sectionNumber]
        
        let container = UIView()
        let label = UILabel(text: section.title)
        label.font = EntryViewController.headerLabelFont
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(collapseOrExpandSection(sender:)), for: .touchUpInside)
        button.setImage(makeImageSuitableForHeader(systemName: sectionHeaderChevronImageName(forSection: section, snapshot: snapshot)), for: .normal)
        button.tag = sectionNumber
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // if true, then this is the 'Message' cell
        // which we don't want to display a context menu for
        // so that the text is selectable
        if (indexPath.section, indexPath.row) == (0, 0) {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [self] _ in
            // get the value of the cell that was held
            guard let value = dataSource.itemIdentifier(for: indexPath) else { return nil }
            
            // Action to copy the value selected
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = value.secondaryText
            }
            
            var children = [copyAction]
            
            // if this is a path that we can open in Filza or Santander, offer the option to do so
            if value.primaryText == .localized("Path"),
               let suitablePath = value.secondaryText?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                let filzaURL = URL(string: "filza://\(suitablePath)")!
                let santanderURL = URL(string: "santander://\(suitablePath)")!
                
                if UIApplication.shared.canOpenURL(filzaURL) {
                    let filzaOpenAction = UIAction(title: "Open in Filza") { _ in
                        UIApplication.shared.open(filzaURL)
                    }
                    
                    children.append(filzaOpenAction)
                }
                
                if UIApplication.shared.canOpenURL(santanderURL) {
                    let santanderOpenAction = UIAction(title: "Open in Santander") { _ in
                        UIApplication.shared.open(santanderURL)
                    }
                    
                    children.append(santanderOpenAction)
                }
            }
            
            return UIMenu(children: children)
        }
    }
    
    // expands or collapses a section,
    // with the section coming from the button's tag
    @objc
    func collapseOrExpandSection(sender: UIButton) {
        var snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[sender.tag]
        let items = snapshot.itemIdentifiers(inSection: section)
        let newImage: UIImage?
        
        // if the section is empty, it's collapsed, bring back it's items.
        if items.isEmpty {
            snapshot.appendItems(detailItems(section: section), toSection: section)
            newImage = makeImageSuitableForHeader(systemName: "chevron.down")
        } else {
            snapshot.deleteItems(items)
            newImage = makeImageSuitableForHeader(systemName: "chevron.right")
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
        UIView.transition(with: sender,
                          duration: 0.2,
                          options: [.allowAnimatedContent, .transitionFlipFromRight]) {
            sender.setImage(newImage, for: .normal)
        }
    }
    
    func sectionHeaderChevronImageName(forSection section: Section, snapshot: NSDiffableDataSourceSnapshot<Section, DetailItem>) -> String {
        return snapshot.numberOfItems(inSection: section) == 0 ? "chevron.right" : "chevron.down"
    }
    
    func makeImageSuitableForHeader(systemName: String) -> UIImage? {
        return UIImage(systemName: systemName,
                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
    }
}
