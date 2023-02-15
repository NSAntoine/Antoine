//
//  SceneDelegate.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	
    var streamViewController: StreamViewController!
	// the timer used for when background mode is timed
	// ie, if background mode is enabled and the user chose a specific time
	// like a minute, for example,
	// then this timer would trigger after a minute and tell the app to stop
	// collecting logs
    var currentBackgroundTimer: Timer?
	var addBatchUponOpening: Bool = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let windowViewController: UIViewController
        let streamVC = StreamViewController()
        
        if #available(iOS 14.0, *), UIDevice.current.userInterfaceIdiom == .pad, Preferences.useiPadMode {
            let splitVC = UISplitViewController(style: .doubleColumn)
            splitVC.setViewController(streamVC, for: .secondary)
            windowViewController = splitVC
        } else {
            windowViewController = UINavigationController(rootViewController: streamVC)
        }
        
        self.streamViewController = streamVC
        window.rootViewController = windowViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        NSLog("Five star dishes, different exotic fishes")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        currentBackgroundTimer?.invalidate()
        ApplicationMonitor.shared.stop()
		
		// add items that were collected in background
		// if necessary
		if addBatchUponOpening {
			streamViewController.addBatch()
			addBatchUponOpening = false
		}
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // enable background mode if needed
        backgroundModeHandler()
    }
    
    func backgroundModeHandler() {
        guard let mode = Preferences.backgroundMode else {
            return
        }
		
        // make sure location services are enabled
		guard ApplicationMonitor.shared.locationManager.currentAuthorizationStatus() == .authorizedAlways else {
			ApplicationMonitor.shared.sendNotification(
				title: .localized("Couldn't start background mode"),
				body: .localized("Antoine needs Always-On Location Authorization in order to enable Background Mode"),
				categoryId: "BackgroundModeWarnings")
			return
		}
		
        switch mode {
        case .backgroundTime(let time):
            ApplicationMonitor.shared.start()
            let tmr = Timer(timeInterval: time, repeats: false) { [unowned self] _ in
				backgroundModeFinished()
            }
            
            RunLoop.current.add(tmr, forMode: .default)
            currentBackgroundTimer = tmr
        case .indefinitely:
            ApplicationMonitor.shared.start()
        }
        
		ApplicationMonitor.shared.addAction(title: .localized("Pause"), actionIdentifier: "LoggingStarted", categoryIdentifier: "LoggingStarted")
		
        ApplicationMonitor.shared.sendNotification(
            title: .localized("Background Mode"),
            body: .localized("Antoine is now collecting logs in the background"),
			categoryId: "LoggingStarted"
        )
    }
	
	// called when the background mode is done
	// while the user is still in the background
	// ie, when the timer finishes
	func backgroundModeFinished(sendNotification: Bool = true) {
		// tell the app we want to add the batch collected once we open the app
		addBatchUponOpening = streamViewController.logStream.isStreaming
		// stop once we're done
		streamViewController.logStream.cancel()
		
		if sendNotification {
			ApplicationMonitor.shared.sendNotification(
				title: .localized("Stopped"),
				body: .localized("App has stopped collecting logs in background"),
				categoryId: nil,
				requestID: "CollectingStopped"
			)
		}
		
		ApplicationMonitor.shared.stop()
		currentBackgroundTimer?.invalidate()
	}
}
