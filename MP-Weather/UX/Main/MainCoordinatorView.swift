//
//  MainCoordinatorView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

struct MainCoordinatorView: View {
    
    @State var coordinator: MainCoordinator
    
    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            ForecastCoordinatorView(coordinator: coordinator.forecastCoordinator)
                .tag(MainTab.forecast.rawValue)
                .tabItem{ Label(MainTab.forecast.tabName, systemImage: MainTab.forecast.systemIconName)}
            SearchCoordinatorView(coordinator:coordinator.searchCoordinator)
                .tag(MainTab.search.rawValue)
                .tabItem{ Label(MainTab.search.tabName, systemImage: MainTab.search.systemIconName)}
            SettingsView()
                .tag(MainTab.settings.rawValue)
                .tabItem{ Label(MainTab.settings.tabName, systemImage: MainTab.settings.systemIconName)}
        }
    }
}
