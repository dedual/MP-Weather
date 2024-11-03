//
//  SearchViewModel.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

@Observable
class SearchViewModel {
    unowned let coordinator:SearchCoordinator
    
    private let weatherAPI:APIManager
    private let locationManager:LocationManager

    var previousLocations = Set<LocationInfo>()
    var searchLocationsText:String = ""
    
    var retrievedLocations: [LocationInfo] = []
    
    var filteredRetrievedLocations: [LocationInfo]
    {
        if searchLocationsText.isEmpty {
            return []
        }
        else
        {
            return retrievedLocations
        }
    }
    
    var showAlert:Bool = false
    var showAlertMessage:String?
    
    // MARK: - Initialization
    init(coordinator: SearchCoordinator, weatherAPI: APIManager, locationManager:LocationManager) {
        
        self.coordinator = coordinator
        self.weatherAPI = weatherAPI
        self.locationManager = locationManager
        
        self.showAlert = false
        self.showAlertMessage = nil
        
        self.searchLocationsText = ""
        self.retrievedLocations = []
        self.previousLocations = []
    }
    
    // MARK: - Methods
    
    @MainActor
    func switchTo(tab:MainTab) {
        coordinator.switchTo(tab: tab)
    }
    
    // MARK: - API Requests
    func runSearch(searchLocation:String) async {
        
        if searchLocation.count > 2 {
            do{
                let locations = try await weatherAPI.getTempLocationsInfoFromQuery(address: searchLocation)
                retrievedLocations = locations
            }
            catch {
                showAlertMessage = error.localizedDescription
                showAlert = true
            }
        }
        else {
            retrievedLocations = []
        }
    }
}
