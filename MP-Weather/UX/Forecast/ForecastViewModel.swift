//
//  ForecastViewModel.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

@Observable
class ForecastViewModel {
    unowned let coordinator:ForecastCoordinator
    
    private let weatherAPI:APIManager
    private let locationManager:LocationManager
    
    private(set) var currentForecast:CurrentForecast?
    private(set) var multidayForecast:MultiDayForecast?
    
    private var cleanupTimer:Timer?

    var showAlert:Bool = false
    private(set) var isLoading:Bool = false
    private(set) var showAlertMessage:String?
    
    // MARK: - Initialization
    init(coordinator: ForecastCoordinator, weatherAPI: APIManager, locationManager:LocationManager) {
        
        self.coordinator = coordinator
        self.weatherAPI = weatherAPI
        self.locationManager = locationManager
        
        self.currentForecast = nil
        self.multidayForecast = nil
        
        self.showAlert = false
        self.isLoading = false
        self.showAlertMessage = nil
    }
    
    // MARK: - Methods
    @MainActor
    func switchTo(tab:MainTab) {
        coordinator.switchTo(tab: tab)
    }
    
    func cleanNumberDisplay(_ input:Double) -> String {
        let formatter = NumberFormatter()

        formatter.usesSignificantDigits = true
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 2
        
        if let result = formatter.string(from: input as NSNumber) {
            return result
        }
        else
        {
            return "\(input)"
        }
    }
    
    func makeHourText(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    func makeDayText(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: date)
    }
    
    // MARK: - API Calls
    
    private func refreshForecast(lat:Double, lon:Double) async {
        isLoading = true
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { aTimer in
            Task{@MainActor in
                self.isLoading = false
            }
        }
        do{
            let tempWeather = try await weatherAPI.currentForecast(latitude: lat, longitude: lon)
            let tempMultiForecast = try await weatherAPI.multidayForecast(latitude: lat, longitude: lon)
            
            self.currentForecast = tempWeather
            self.multidayForecast = tempMultiForecast
            
            UserPreferences.lastRetrievedLocationInfo = tempWeather.locationInfo
            UserPreferences.lastUpdated = .now
            showAlertMessage = nil

            showAlert = false
            isLoading = false
        }
        catch let error as RequestError {
            showAlertMessage = error.customMessage
            showAlert = true
            isLoading = false
            return
        }
        catch {
            showAlertMessage = error.localizedDescription
            showAlert = true
            isLoading = false
            return 
        }
    }
    
    func refreshForecast(locationInfo:LocationInfo) async {
        await refreshForecast(lat: locationInfo.owLat, lon: locationInfo.owLon)
    }
    
    func refreshForecastUsingLocation() async {
        do {
            locationManager.checkAuthorization()

            let location = try await locationManager.currentLocation
            await self.refreshForecast(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
        catch let error as LocationError {
            if error != .awaitingPermission {
                showAlertMessage = error.customMessage
                showAlert = true
            }
            isLoading = false
        }
        catch {
            showAlertMessage = error.localizedDescription
            showAlert = true
            isLoading = false
        }
    }
}
