//
//  Environment.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

public enum Environment {
    enum Keys {
        static let openWeatherAPIKey = "OPENWEATHER_API_KEY"
        static let baseUrl = "OPENWEATHER_BASE_URL"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else
        {
            fatalError("plist file not found")
        }
        
        return dict
    }()
    
    static let openWeatherBaseURL:String = {
        guard let baseURLString = Environment.infoDictionary[Keys.baseUrl] as? String else {
            fatalError("Base URL not set in plist")
        }
        return baseURLString
    }()
    
    static let openWeatherAPIKey:String = {
        guard let apiKeyString = Environment.infoDictionary[Keys.openWeatherAPIKey] as? String else {
            fatalError("API Key has not been set in plist. Maybe secrets.xcconfig is missing?")
        }
        return apiKeyString
    }()
}
