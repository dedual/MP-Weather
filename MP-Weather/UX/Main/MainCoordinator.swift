//
//  MainCoordinator.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

enum MainTab:Int {
    case forecast = 0
    case search = 1
    case settings = 2
    
    var tabName:String {
        switch self {
            
        case .forecast:
            return "Current"
        case .search:
            return "Locations"
        case .settings:
            return "Settings"
        }
    }
    
    var systemIconName:String {
        switch self {
        case .forecast:
            return "network"
        case .search:
            return "magnifyingglass"
        case .settings:
            return "gearshape"
        }
    }
}

@MainActor
@Observable
class MainCoordinator {
    
    var weatherAPI:APIManager
    var locationManager:LocationManager
    
    var selectedTab:Int = MainTab.forecast.rawValue
    
    var forecastCoordinator: ForecastCoordinator!
    var searchCoordinator: SearchCoordinator!
    
    init() {
        weatherAPI = APIManager()
        locationManager = LocationManager()
        
        forecastCoordinator = .init(parent: self)
        searchCoordinator = .init(parent: self)
    }
    
    func switchToTab(tab:MainTab) {
        selectedTab = tab.rawValue
    }
}
