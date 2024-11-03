//
//  LocationManager.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    static var authStatus:Bool = false
    
    var currentLocation:CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation{ continuation in
                self.continuation = continuation
                locationManager.requestLocation()
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
    }
    
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            continuation?.resume(throwing: LocationError.awaitingPermission)
            continuation = nil
            LocationManager.authStatus = false
        case .denied:
            continuation?.resume(throwing: LocationError.denied("We are unable to retrieve your device's location via Location Services.\nPlease authorize."))
            continuation = nil
            LocationManager.authStatus = false
        case .restricted:
            continuation?.resume(throwing: LocationError.denied("We are unable to retrieve your device's location via Location Services.\nPlease authorize."))
            continuation = nil
            LocationManager.authStatus = false
        default:
            LocationManager.authStatus = true
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let lastLocation = locations.last {
                continuation?.resume(returning: lastLocation)
                continuation = nil
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        continuation?.resume(throwing: LocationError.unknown(error.localizedDescription))
        continuation = nil
    }
}
