//
//  SearchCoordinator.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

@MainActor
@Observable

final class SearchCoordinator:Identifiable {
    private unowned let parent: MainCoordinator
    
    var viewModel:SearchViewModel!
    
    init(parent: MainCoordinator) {
        self.parent = parent
        self.viewModel = SearchViewModel(coordinator: self, weatherAPI: parent.weatherAPI, locationManager: parent.locationManager)
    }
    
    func switchTo(tab:MainTab) {
        self.parent.switchToTab(tab: tab)
    }
}
