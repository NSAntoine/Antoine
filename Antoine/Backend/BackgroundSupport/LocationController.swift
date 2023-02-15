//
//  LocationController.swift
//  Antoine
//
//  Created by Serena on 11/02/2023.
//

import CoreLocation

// https://github.com/sourcelocation/Evyrest/blob/main/Evyrest/Controllers/LocationManager.swift
class LocationController: NSObject, CLLocationManagerDelegate {
    typealias Status = Result<Void, Error>
    
    let locationManager: CLLocationManager
    var status: Status?
	
	func currentAuthorizationStatus() -> CLAuthorizationStatus {
		if #available(iOS 14, *) {
			return locationManager.authorizationStatus
		}
		
		return CLLocationManager.authorizationStatus()
	}
	
    override init() {
        let locationManager = CLLocationManager()
		
		
        locationManager.distanceFilter = CLLocationDistanceMax
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        if #available(iOS 14, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
        
        self.locationManager = locationManager
        
        super.init()
        
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
		case .restricted, .authorizedWhenInUse, .authorized, .denied:
            self.status = .failure(Errors.requiresAlwaysAuthorizaion)
        case .authorizedAlways:
            start()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        status = .success(())
    }
    
    func start() {
        switch status {
        case .failure, nil:
            let status: CLAuthorizationStatus
            
            if #available(iOS 14, *) {
                status = locationManager.authorizationStatus
            } else {
                status = CLLocationManager.authorizationStatus()
            }
            
            switch status {
            case .notDetermined, .authorizedWhenInUse:
                locationManager.requestAlwaysAuthorization()
            default:
                locationManager.startUpdatingLocation()
            }
            
        default:
            break
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        NSLog(#function)
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        status = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError, clError.code != .denied else {
            status = .failure(error)
            return
        }
        
        status = .failure(Errors.requiresAlwaysAuthorizaion)
    }
    
    enum Errors: Error, LocalizedError, CustomStringConvertible {
        case requiresAlwaysAuthorizaion
        
        var description: String {
            switch self {
            case .requiresAlwaysAuthorizaion:
				return "For background mode, please authorize the app with Always-On Location Services"
					.localized()
            }
        }
        
        var errorDescription: String? {
            description
        }
    }
}
