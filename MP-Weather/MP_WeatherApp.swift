//
//  MP_WeatherApp.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

@main
struct MP_WeatherApp: App {
        
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(coordinator: MainCoordinator())
        }
    }
}
