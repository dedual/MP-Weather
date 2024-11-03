//
//  ForecastCoordinator.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

@MainActor
@Observable

final class ForecastCoordinator:Identifiable {
    private unowned let parent: MainCoordinator
    
    var viewModel:ForecastViewModel!
    
    init(parent: MainCoordinator) {
        self.parent = parent
        self.viewModel = ForecastViewModel(coordinator: self, weatherAPI: parent.weatherAPI, locationManager: parent.locationManager)
    }
    
    func switchTo(tab:MainTab) {
        self.parent.switchToTab(tab: tab)
    }
}
