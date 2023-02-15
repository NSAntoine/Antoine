//
//  ApplicationMonitor.swift
//  Antoine
//
//  Created by Serena on 11/02/2023.
//

import UIKit
import AVFoundation

private extension CFNotificationName {
    static let appIsRunning = CFNotificationName("com.serena.Antoine.Running" as CFString)
}

private let requestAppStateCallback: @convention(c) (CFNotificationCenter?, UnsafeMutableRawPointer?, CFNotificationName?, UnsafeRawPointer?, CFDictionary?) -> Void = { (_, _, _, _, _) in
    ApplicationMonitor.shared.receivedApplicationStateRequest()
}

// https://github.com/sourcelocation/Evyrest/blob/main/Evyrest/Controllers/ApplicationMonitor.swift
#warning("To Do: use a audio player based solution rather than location")
class ApplicationMonitor: NSObject, UNUserNotificationCenterDelegate/*, AVAudioPlayerDelegate*/ {
    static let shared = ApplicationMonitor()
    
    let applicationNotificationRequest = "com.serena.Antoine.ApplicationNowInBackground"
    
    let locationManager = LocationController()
    
    var isMonitoring = false
    
	/*var audioPlayer: AVAudioPlayer!*/
	override init() {
		super.init()
		
		UNUserNotificationCenter.current().delegate = self
	}
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
		case "LoggingStarted":
			// pause ongoing log collection
			let delegate = (response.targetScene?.delegate as? SceneDelegate)
			delegate?.backgroundModeFinished(sendNotification: true)
		default:
			break
		}
		
		completionHandler()
	}
	
    func start() {
        guard !isMonitoring else {
            return
        }
        
		
        isMonitoring = true
        cancelAppQuitNotif()
        
        locationManager.start()
        registerForNotifs()
    }
    
    func stop() {
        isMonitoring = false
        locationManager.stop()
    }
    
	/*
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("finished")
		
	}
	 */
	
    func registerForNotifs() {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            requestAppStateCallback,
            "com.serena.Antoine.RequestAppState" as CFString,
            nil,
            .deliverImmediately
        )
    }
    
    func cancelAppQuitNotif() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    
	func sendNotification(title: String,
						  body: String,
						  categoryId: String?,
						  delay: TimeInterval = 1,
						  requestID: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
		
		if let categoryId {
			content.categoryIdentifier = categoryId
		}
		
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
		let request = UNNotificationRequest(identifier: requestID ?? applicationNotificationRequest, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
	
	func addAction(title: String, actionIdentifier: String, categoryIdentifier: String) {
		let action = UNNotificationAction(identifier: actionIdentifier,
										  title: title)
		
		let category = UNNotificationCategory(
			identifier: categoryIdentifier,
			actions: [action],
			intentIdentifiers: [],
			options: .customDismissAction
		)
		
		UNUserNotificationCenter.current().setNotificationCategories([category])
	}
    
    func receivedApplicationStateRequest() {
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(
            center,
            .appIsRunning,
            nil, nil, true
        )
    }
}
