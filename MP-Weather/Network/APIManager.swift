//
//  APIManager.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI
import MapKit

protocol APIManagerProtocol
{
    func currentForecast(latitude:Double, longitude:Double) async throws -> CurrentForecast
    func currentForecast(address:String) async throws -> CurrentForecast
    func multidayForecast(latitude:Double, longitude:Double) async throws -> MultiDayForecast
    func multidayForecast(address:String) async throws -> MultiDayForecast

}

@Observable
public class APIManager: HTTPClient, APIManagerProtocol
{
    static let refreshInterval = TimeInterval(NetworkingConstants.OpenWeather.staleness_timelapse_seconds)

    private let geocoder = CLGeocoder()
    private let localRequest = MKLocalSearch.Request()
    
    private var lastUpdated: Date {
       get {
          UserDefaults.standard.object(forKey: UserPreferences.Keys.lastUpdated) as! Date
       }
       set {
          UserDefaults.standard.set(newValue, forKey: UserPreferences.Keys.lastUpdated)
       }
    }
    
    private var shouldUpdate: Bool {
        if abs(lastUpdated.timeIntervalSinceNow) > APIManager.refreshInterval {
          return true
       }
       return false
    }
    
    // MARK: - Geocoder helper (private)
    private func getGeocoderValue(address:String) async throws -> CLLocationCoordinate2D? {
        let placemarks = try await geocoder.geocodeAddressString(address)
        
        let validLocations = placemarks.compactMap { aPlacemark in
            if let location = aPlacemark.location
            {
                return location.coordinate
            }
            else
            {
                return nil
            }
        }
        
        if validLocations.count == 0
        {
            // Something went wrong, let's try with OpenWeather's query
            return nil
        }
        
        return validLocations.first! // why first? Apple only returns one value via CLGeocoder
    }
    
    // MARK: - API Calls -
    func currentForecast(latitude: Double, longitude: Double) async throws -> CurrentForecast {
        return try await sendRequest(endpoint: .current(lat: latitude, lon: longitude), responseModel: CurrentForecast.self)
    }
    
    func currentForecast(address: String) async throws -> CurrentForecast {
        
        // get Lat/Lon from Apple's Geocoder

        let location = try await getGeocoderValue(address: address)
        
        if let currentLocation = location
        {
            return try await sendRequest(endpoint: .current(lat: currentLocation.latitude, lon: currentLocation.longitude), responseModel: CurrentForecast.self)
        }
        // why do this?
        // 1) Seems OpenWeatherAPI better supports GPS-derived results rather than queries, and we don't want to query the API again
        // as that costs money
        // 2) There was a notice that the query-based results were going to be deprecated? Out of an overabundance of caution, we'll default to Apple results first
        
        if let validAddress = returnValidAddressQueryString(address)
        {
            return try await sendRequest(endpoint: .currentWithQuery(query: validAddress), responseModel: CurrentForecast.self)
        }
        
        return try await sendRequest(endpoint: .currentWithQuery(query: address), responseModel: CurrentForecast.self)
    }
    
    func multidayForecast(latitude: Double, longitude: Double) async throws -> MultiDayForecast {
        return try await sendRequest(endpoint: .forecast(lat: latitude, lon: longitude), responseModel: MultiDayForecast.self)
    }
    
    func multidayForecast(address: String) async throws -> MultiDayForecast {
        let location = try await getGeocoderValue(address: address)
        
        if let currentLocation = location {
            return try await sendRequest(endpoint: .forecast(lat: currentLocation.latitude, lon: currentLocation.longitude), responseModel: MultiDayForecast.self)
        }
                
        if let validAddress = returnValidAddressQueryString(address) {
            return try await sendRequest(endpoint: .currentWithQuery(query: validAddress), responseModel: MultiDayForecast.self)
        }
        
        return try await sendRequest(endpoint: .forecastWithQuery(query: address), responseModel: MultiDayForecast.self)
    }
    
    // MARK: - API helper calls -
    func returnValidAddressQueryString(_ query:String) -> String? {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
        let matches = detector.matches(in: query, options: [], range: NSRange(location: 0, length: query.utf16.count))
        
        var resultsArray =  [[NSTextCheckingKey: String]]()
        
        for match in matches {
            if match.resultType == .address,
              let components = match.addressComponents {
                resultsArray.append(components)
            }
        }
                
        if let first = resultsArray.first {
            let OWAPI_SanitizedQueryAddress = (first[.city] != nil ? (first[.city]! + ", ") : "") + (first[.state] != nil ? (first[.state]! + ", ") : "")  + (first[.country] != nil ? (first[.country]! + ", ") : "")
            return OWAPI_SanitizedQueryAddress
        }
        
        return nil
    }
    
    func getTempLocationsInfoFromQuery(address:String) async throws -> [LocationInfo] {
        var locations = [LocationInfo]()
        
        if let validAddress = returnValidAddressQueryString(address)
        {
            locations = try await sendRequest(endpoint: .geocode(query: validAddress), responseModel: [LocationInfo].self)
            return locations
        }
        
        locations = try await sendRequest(endpoint: .geocode(query: address), responseModel: [LocationInfo].self)

        return locations
    }
}
