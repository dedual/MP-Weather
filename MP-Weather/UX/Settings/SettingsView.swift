//
//  SettingsView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var selectedUnit:TemperatureUnit = UserPreferences.getPreferredMeasurementUnit
    @State private var preferredLanguage:String =  UserPreferences.getPreferredLanguage
    @State private var alwaysUseLocation:Bool = UserPreferences.alwaysUseUserLocation
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("User Preferences"),
                        footer: Text("Here we can define some typical user preferences we use within the application")) {
                    Picker("Preferred temperature units", selection: $selectedUnit) {
                        ForEach(TemperatureUnit.all, id: \.self) { aTemperatureUnit in
                            Text(aTemperatureUnit.label).tag(aTemperatureUnit)
                        }
                    }.onChange(of: selectedUnit) { _ , newValue in
                        UserPreferences.setPreferredMeasurementUnit(value: newValue.rawValue)
                    }
                    
                    Picker("Preferred Language", selection: $preferredLanguage) {
                        
                        ForEach(UserPreferences.languagePListDict.sorted(by: <), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }.onChange(of: preferredLanguage) { _ , newValue in
                        UserPreferences.setPreferredLanguage(value: newValue)
                    }
                    
                    Toggle(isOn: $alwaysUseLocation) {
                        Text("Always use device location on app load")
                    }.onChange(of: alwaysUseLocation){_, newValue in
                    
                        UserPreferences.alwaysUseUserLocation = newValue
                        
                    }.disabled(!LocationManager.authStatus)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
