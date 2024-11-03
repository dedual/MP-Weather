//
//  LocationManager.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var nillableContinuation: CheckedContinuation<CLLocation, Error>?
    
    static var authStatus:Bool = false
    
    var currentLocation:CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation{ continuation in
                self.nillableContinuation = continuation
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
            if let continuation = nillableContinuation {
                nillableContinuation = nil
                continuation.resume(throwing: LocationError.awaitingPermission)
                LocationManager.authStatus = false
            }
        case .denied:
            if let continuation = nillableContinuation {
                nillableContinuation = nil
                continuation.resume(throwing: LocationError.denied("We are unable to retrieve your device's location via Location Services.\nPlease authorize."))
                LocationManager.authStatus = false
            }
        case .restricted:
            if let continuation = nillableContinuation {
                nillableContinuation = nil
                continuation.resume(throwing: LocationError.denied("We are unable to retrieve your device's location via Location Services.\nPlease authorize."))
                LocationManager.authStatus = false
            }
        default:
            LocationManager.authStatus = true
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            if let continuation = nillableContinuation {
                    nillableContinuation = nil
                    continuation.resume(returning: lastLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let continuation = nillableContinuation {
            continuation.resume(throwing: LocationError.unknown(error.localizedDescription))
            nillableContinuation = nil
        }
    }
}
