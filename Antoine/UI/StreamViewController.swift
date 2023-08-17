//
//  StreamViewController.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import UIKit
import ActivityStreamBridge
import os.log

/// A View Controller displaying Log Entires / Log Messages
/// that are reported by the OS in real time.
class StreamViewController: UIViewController {
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, StreamEntry>
    var dataSource: DataSource!
    var collectionView: UICollectionView!
    var amountOfItemsLabel: UILabel!
    var currentlyShownEntryViewController: EntryViewController?
    var filter: EntryFilter? = Preferences.entryFilter {
        didSet {
            Preferences.entryFilter = filter
        }
    }
    
    // Keep this bar button item here so we can enable it and disable it when we want to
    // without having to rebuild all toolbar items
    lazy var scrollDownBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(scrollAllTheWayDown))
        item.isEnabled = false // false by default
        return item
    }()
    
    // Similar reason to keep this as a variable as the `scrollDownBarButtonItem`
    // But for this, it's so that we can update the image of the item without reloading the entire bar
    lazy var playPauseButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "pause.fill"),
                               style: .plain, target: self,
                               action: #selector(stopOrStartStream))
    }()
    
    var options: StreamOption = StreamOption(rawValue: UserDefaults.standard.integer(forKey: "StreamOptionsRawValue")) {
        didSet {
            UserDefaults.standard.set(options.rawValue, forKey: "StreamOptionsRawValue")
            if logStream.isStreaming {
                logStream.cancel()
                logStream.start(options: options)
            }
        }
    }
    
    lazy var logStream: ActivityStream = {
        let stream = ActivityStream()
        stream.delegate = self
        return stream
    }()
    
    /// whether or not to automatically scroll to the bottom every time a batch of entries is recieved
    var automaticallyScrollToBottom: Bool = true
    
    let numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        fmt.numberStyle = .decimal
        return fmt
    }()
    
    /// this batch is used for performance reasons,
    /// entries are temporarily added to this batch array,
    /// then, once the timer runs, the items from it are added and the batch array
    /// is emptied
    var batch: [StreamEntry] = []
    
    lazy var timer = makeTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        let streamTitleLabel = UILabel(text: .localized("Stream"))
        streamTitleLabel.textAlignment = .center
        streamTitleLabel.font = (navigationController?.navigationBar.value(forKey: "_defaultTitleFont") as? UIFont) ?? .boldSystemFont(ofSize: 17)
        amountOfItemsLabel = UILabel() // no text yet till we actually get an item
        amountOfItemsLabel.font = .preferredFont(forTextStyle: .caption2)
        amountOfItemsLabel.textAlignment = .center
        
        let titleStackView = UIStackView(arrangedSubviews: [streamTitleLabel, amountOfItemsLabel])
        titleStackView.axis = .vertical
        navigationItem.titleView = titleStackView
        
        setupCollectionView()
        makeDataSource()
        setToolbarItems()
        
        NSLog("And we all wanna be happy..")
        NSLog("DO I LOOK HAPPY?")
        NSLog("DO I LOOK HAPPY TO YOU?")
        
        RunLoop.current.add(timer, forMode: .common)
        
        navigationItem.rightBarButtonItem = makePreferencesBarButtonItem()
        navigationItem.leftBarButtonItem = makeOptionsEditBarButtonItem()
        
        splitViewController?.presentsWithGesture = false
        splitViewController?.preferredDisplayMode = .allVisible
        
        // register for when the timer interval changes
        NotificationCenter.default.addObserver(forName: .streamTimerIntervalDidChange,
                                               object: nil,
                                               queue: nil) { notif in
            guard let newTimerInterval = notif.object as? TimeInterval else {
                fatalError("SHOULD NOT HAVE GOTTEN HERE!! SANITY CHECK, NOW!")
            }
            
            print("newTimerInterval: \(newTimerInterval)")
            self.timer.invalidate()
            self.timer = self.makeTimer(interval: newTimerInterval)
            RunLoop.main.add(self.timer, forMode: .common)
        }
        
        ActivityStream.enableShowPrivateData(Preferences.showPrivateData)
        
        /*
         hmmm...
		if #available(iOS 14, *) {
			splitViewController?.delegate = self
		}
         */
        
        /*
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
         */
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logStream.start(options: options)
    }
    
    @objc
    func presentSettingsVC() {
        present(UINavigationController(rootViewController: PreferencesViewController(nibName: nil, bundle: nil)), animated: true)
    }
    
    // override present(_:, animated:) so that when we want to present a view controller
    // and one is already present,
    // dismiss the already-presented view controller, then show our view controller
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let presentedViewController {
            presentedViewController.dismiss(animated: flag) {
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension StreamViewController: EntryFilterViewControllerDelegate {
    // MARK: - Filter stuff
    @objc
    func presentFilterVC() {
        let filterVC = EntryFilterViewController(filter: filter)
        filterVC.delegate = self
        let vc = UINavigationController(rootViewController: filterVC)
        present(vc, animated: true)
    }
    
    func didFinishEditing(_ controller: EntryFilterViewController) {
        filter = controller.filter
    }
}

extension StreamViewController {
    @objc func scrollAllTheWayDown() {
        collectionView.scrollToItem(at: IndexPath(row: dataSource.snapshot().numberOfItems - 1, section: 0),
                                    at: .bottom,
                                    animated: true)
        scrollDownBarButtonItem.isEnabled = false
        automaticallyScrollToBottom = true
    }
    
    // MARK: - Bar Button items
    @objc func stopOrStartStream() {
        let isStreaming = logStream.isStreaming
        playPauseButtonItem.image = UIImage(systemName: isStreaming ? "play.fill" : "pause.fill")
        isStreaming ? logStream.cancel() : logStream.start(options: options)
    }
    
    /// Converts all ``TitledStreamOption`` instances to MenuItems
    private func titledStreamOptionsToMenuItems() -> [MenuItem] {
        // Stream option set
        return TitledStreamOption.all.map { opt in
            return MenuItem(title: opt.title, image: nil, isEnabled: options.contains(opt.option)) { [self] in
                options.removeOrInsertBasedOnExistance(opt.option)
                
                navigationItem.leftBarButtonItem = makeOptionsEditBarButtonItem()
            }
        } + [makeToggleShowPrivateMenuItem()]
    }
    
    private func makeToggleShowPrivateMenuItem() -> MenuItem {
        return MenuItem(title: .localized("Show Private data in most Logs (gets rid of <private>)"), image: nil, isEnabled: Preferences.showPrivateData) { [self] in
            var newValue = Preferences.showPrivateData
            
            // toggle bc the user just did so
            newValue.toggle()
            
            ActivityStream.enableShowPrivateData(newValue)
            Preferences.showPrivateData = newValue
            
            // Reload bar
            navigationItem.leftBarButtonItem = makeOptionsEditBarButtonItem()
        }
    }
    
    /// Presents a UIAlertController for adding / removing stream options
    @objc
    private func presentActionSheetForStreanOptions() {
        let alert = UIAlertController(title: .localized("Stream Options"), message: nil, preferredStyle: .actionSheet)
        for item in titledStreamOptionsToMenuItems() {
            alert.addAction(item.uiAlertAction)
        }
        
        alert.addAction(UIAlertAction(title: .localized("Cancel"), style: .cancel))
        present(alert, animated: true)
    }
    
    func makeOptionsEditBarButtonItem() -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            let actions = titledStreamOptionsToMenuItems()
            
            return UIBarButtonItem(
                image: UIImage(systemName: "list.bullet.rectangle"),
                menu: MenuItem.makeMenu(title: .localized("Stream Options"), for: actions)
            )
        }
        
        return UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(presentActionSheetForStreanOptions))
    }
    
    func makeToolbarItems() -> [UIBarButtonItem] {
        return [
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(presentFilterVC)),
            .space(.flexible),
            playPauseButtonItem,
            .space(.flexible),
            scrollDownBarButtonItem,
            .space(.flexible),
            UIBarButtonItem(image: UIImage(systemName: "xmark.circle"),
                            style: .done, target: self,
                            action: #selector(clearAll)),
        ]
    }
    
	func makePreferencesBarButtonItem() -> UIBarButtonItem {
		return UIBarButtonItem(image: UIImage(systemName: "gear"),
						style: .plain, target: self,
						action: #selector(presentSettingsVC))
	}
	
    func setToolbarItems() {
        setToolbarItems(makeToolbarItems(), animated: true)
    }
    
    @objc
    func clearAll() {
        var snapshot: NSDiffableDataSourceSnapshot<Section, StreamEntry> = .init()
        snapshot.appendSections([.main])
        dataSourceApply(snapshot: snapshot)
    }
	
    func dataSourceApply(snapshot: NSDiffableDataSourceSnapshot<Section, StreamEntry>) {
        
        dataSource.apply(snapshot) {
            self.amountOfItemsLabel.text = .localized("%@ Logs", arguments: self.numberFormatter.string(from: snapshot.numberOfItems as NSNumber) ?? snapshot.numberOfItems.description)
        }
    }
    
    func makeTimer(interval: TimeInterval = Preferences.streamVCTimerInterval) -> Timer {
        return Timer(timeInterval: interval, repeats: true) { [self] _ in
            // if we're paused,
			// or collecting logs in background
			// let's stop here, keep the batch for when we do want
			// to display it
			guard logStream.isStreaming,
					UIApplication.shared.applicationState != .background else {
				return
			}
			
            addBatch()
            if automaticallyScrollToBottom {
                scrollAllTheWayDown()
            }
        }
    }
	
	func addBatch() {
		var snapshot = dataSource.snapshot()
		snapshot.appendItems(batch)
		batch = []
		//NSLog("Timer closure")
        dataSourceApply(snapshot: snapshot)
	}
}

extension StreamViewController: UICollectionViewDelegate {
    // MARK: UICollectionView management, setting up bar items, etc
    func setupCollectionView() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.constraintCompletely(to: view)
        
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.delegate = self
        
        collectionView.register(EntryCollectionViewCell.self,
                                forCellWithReuseIdentifier: EntryCollectionViewCell.reuseIdentifier)
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(75))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
		//section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: spacing,
                                                        bottom: 0,
                                                        trailing: spacing)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func makeDataSource() {
        if #available(iOS 14.0, *), getenv("ANTOINE_DATA_SOURCE_NO_CELL_REGISTRATION") == nil {
            let cellRegistration = UICollectionView.CellRegistration<EntryCollectionViewCell, StreamEntry> { cell, indexPath, itemIdentifier in
                cell.configure(message: itemIdentifier)
            }
            
            dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        } else {
            dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCollectionViewCell.reuseIdentifier, for: indexPath) as! EntryCollectionViewCell
                cell.configure(message: itemIdentifier)
                return cell
            }
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        dataSourceApply(snapshot: snapshot)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDownBarButtonItem.isEnabled = true
        automaticallyScrollToBottom = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDownBarButtonItem.isEnabled = true
        automaticallyScrollToBottom = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        presentEntryViewController(for: item)
    }
    
    func presentEntryViewController(_ controller: EntryViewController) {
        if #available(iOS 14, *), let splitViewController, Preferences.useiPadMode {
            if splitViewController.viewController(for: .secondary) is EntryViewController {
                // retain cycle happens if u don't do this lol
                splitViewController.setViewController(nil, for: .secondary)
            }
            
            if splitViewController.viewController(for: .primary) != self {
                splitViewController.setViewController(self, for: .primary)
            }
            currentlyShownEntryViewController = controller
            splitViewController.setViewController(currentlyShownEntryViewController, for: .secondary)
        } else {
            let vc = UINavigationController(rootViewController: controller)
            
            if #available(iOS 15.0, *), UIDevice.current.userInterfaceIdiom == .pad,
               let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.detents = [.medium(), .large()]
                sheet.preferredCornerRadius = 20
                //sheet.largestUndimmedDetentIdentifier = .large
            }
            
            present(vc, animated: true)
        }
    }
    
    func presentEntryViewController(for entry: StreamEntry) {
        presentEntryViewController(EntryViewController(entry: entry))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let entry = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return EntryViewController(entry: entry)
        }, actionProvider: { _ in
            func _makeCopyUIAction(title: String, stringToCopy: String) -> UIAction {
                return UIAction(title: title) { _ in
                    UIPasteboard.general.string = stringToCopy
                }
            }
            
            let copyName = _makeCopyUIAction(title: "Process Name", stringToCopy: entry.process)
            let copyPath = _makeCopyUIAction(title: "Process Path", stringToCopy: entry.processImagePath)
            let copyMessage = _makeCopyUIAction(title: "Message", stringToCopy: entry.eventMessage)
            let embeddedCopyMenu = UIMenu(title: "Copy..",
                                          image: UIImage(systemName: "doc.on.doc"),
                                          children: [copyName, copyMessage, copyPath])
            let shareAction = UIAction(title: .localized("Share Log"), image: UIImage(systemName: "square.and.arrow.up")) { [unowned self] _ in
                let bounds: CGRect = view.bounds
                
                export(entry: entry, senderView: view, senderRect: CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0))
            }
            
			return UIMenu(children: [embeddedCopyMenu, shareAction])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let vc = animator.previewViewController as? EntryViewController else { return }
        presentEntryViewController(vc)
        
    }
}

extension StreamViewController: ActivityStreamDelegate {
    func activityStream(streamEventDidChangeTo newEvent: StreamEvent?) {
        // update the play/pause item image
        DispatchQueue.main.async {
            self.playPauseButtonItem.image = UIImage(systemName: self.logStream.isStreaming ? "pause.fill" : "play.fill")
        }
    }
    
    //TODO: - Error handling? But first i'd have to find what the error codes are
    // which I can't seem to find anywhere
    func activityStream(didRecieveEntry entryPointer: os_activity_stream_entry_t, error: CInt) {
        let entry = StreamEntry(entry: entryPointer)
        if filter?.entryPassesFilter(entry) ?? true {
            batch.append(entry)
        }
    }
}

/*
@available(iOS 14.0, *)
extension StreamViewController: UISplitViewControllerDelegate {
	func splitViewController(_ svc: UISplitViewController,
							 willShow column: UISplitViewController.Column) {
		if column == .secondary {
			navigationItem.rightBarButtonItem = UIBarButtonItem(
				image: UIImage(systemName: "xmark.circle"),
				style: .plain, target: self, action: #selector(closeSecondarySplitViewController))
		}
	}
	
	@objc
	func closeSecondarySplitViewController() {
		splitViewController?.setViewController(self, for: .secondary)
		splitViewController?.setViewController(nil, for: .primary)
	}
}
 */

/*
extension StreamViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)
        guard let searchText = searchBar.text else { return }
        let filterToUse: EntryFilter
        let searchTextFilter = TextFilter(text: searchText, mode: .contains)
        if let filter {
            self.filter?.messageTextFilter = searchTextFilter
            self.filter?.process = searchTextFilter
            
            filterToUse = filter
        } else {
            filterToUse = EntryFilter(messageTextFilter: searchTextFilter,
                                 processFilter: searchTextFilter,
                                 pid: nil)
            self.filter = filterToUse
        }
        
        // filter already existing items
//        let filteredItems = dataSource.snapshot().itemIdentifiers.filter { entry in
//            return !filterToUse.entryPassesFilter(entry)
//        }
//
//        var snapshot = NSDiffableDataSourceSnapshot<Section, StreamEntry>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(filteredItems)
//        dataSource.apply(snapshot)

        logStream.cancel()
        logStream.start(options: options)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter = nil
        logStream.cancel()
        logStream.start(options: options)
    }
}
*/
