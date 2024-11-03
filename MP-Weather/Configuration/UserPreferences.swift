//
//  UserPreferences.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

public enum UserPreferences {
    
    // Need to refactor this enum as it's doing a lot that's not strictly tied to "UserPreferences"
    
    enum Keys {
        static let preferredUnits = "PreferredUnits"
        static let lastLocationRetrieved = "LastLocationRetrieved"
        static let preferredLanguage = "PreferredLanguage"
        static let lastUpdated = "LastUpdated"
        static let alwaysUseUserLocation = "AlwaysUseUserLocation"
        static let tempUseUserLocation = "TemporarilyUseUserLocation"

    }
    
    // MARK: - Variables -
    private static let userDefaults = UserDefaults.standard
    
    static let languagePListDict:[String:String] = {
        guard let dictPath = Bundle.main.path(forResource: "SupportedLocales", ofType: "plist") else
        {
            fatalError("Supported locale plist file not found")
        }
        
        guard let nsDict = NSDictionary(contentsOfFile:dictPath) else
        {
            fatalError("Unable to load supported locale plist file")
        }
        
        guard let dict = nsDict as? [String:String] else
        {
            fatalError("Supported locale plist file is unusable")
        }
        return dict
    }()
    
    static var lastRetrievedLocationInfo:LocationInfo? {
        get
        {
            if let locationStored = userDefaults.object(forKey: Keys.lastLocationRetrieved) as? Data
            {
                let decoder = JSONDecoder()
                do{
                    return try decoder.decode(LocationInfo.self, from: locationStored)
                }
                catch
                {
                    print(error)
                    print("?")
                }
                return nil
            }
            else
            {
                return nil
            }
        }
        set
        {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue)
            {
                userDefaults.set(encoded, forKey: Keys.lastLocationRetrieved)
            }
        }
    }
    
    static var alwaysUseUserLocation:Bool
    {
        get
        {
            return userDefaults.bool(forKey: Keys.alwaysUseUserLocation)
        }
        
        set
        {
            userDefaults.setValue(newValue, forKey: Keys.alwaysUseUserLocation)
        }
    }
    
    static var tempUseUserLocation:Bool
    {
        get
        {
            return userDefaults.bool(forKey: Keys.alwaysUseUserLocation)
        }
        
        set
        {
            userDefaults.setValue(newValue, forKey: Keys.alwaysUseUserLocation)
        }
    }
    
    static var lastUpdated:Date? {
        get
        {
            if let dateStored = userDefaults.object(forKey: Keys.lastUpdated) as? Data
            {
                let decoder = JSONDecoder()
                if let date = try? decoder.decode(Date.self, from: dateStored)
                {
                    return date
                }
                return nil
            }
            else
            {
                return nil
            }
        }
        set
        {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue)
            {
                userDefaults.set(encoded, forKey: Keys.lastUpdated)
            }
        }
    }
    
    // Note: with more time, we should test RTL UI support
    
    // MARK: - Internal functions
    static private func ensureValidLocale(value:String) -> String
    {
        // check that the locale provided is supported by OpenWeather
        
        if !UserPreferences.languagePListDict.keys.contains(value)
        {
            return "en" // default to English.
        }
        // I mean, it's very naive. There's several subdivisions of languages that
        // iOS supports that would default to english with this logic.
        // but, it's a start.
        
        return value // safe to use the value provided then
    }
    
    static func getFullLanguagefor(key: String) -> String {
        let key = ensureValidLocale(value: key)
        
        guard let value = UserPreferences.languagePListDict[key] else { return "English"}
        
        return value
    }
    
    static private func ensureValidMeasurementUnit(unit:String) -> TemperatureUnit
    {
        if TemperatureUnit.validUnit(rawString: unit)
        {
            return TemperatureUnit(rawValue: unit) ?? .metric
        }
        
        // check the locale, make assumptions.
        // US-Based locales get Imperial
        // Everyone else gets metric, unless they ask for Kelvin (which is handled in first if test).
        
        if let deviceLanguage = Locale.current.language.languageCode?.identifier
        {
            if deviceLanguage == "en_US_POSIX" ||
                deviceLanguage == "en_US" ||
                deviceLanguage == "haw_US" ||
                deviceLanguage == "es_US" ||
                deviceLanguage == "en"
            {
                return TemperatureUnit.imperial
            }
        }
        
        return TemperatureUnit.metric
        
    }
    
    // MARK: - Public Getters and Setters
    
    // I was tired when writing this. I had forgotten about get set.
    // to rewrite once I rest. - Nick D.
    
    static func setPreferredMeasurementUnit(value:String)
    {
        // clean value
        
        let cleanMeasurementValue = ensureValidMeasurementUnit(unit: value)
        
        userDefaults.setValue(cleanMeasurementValue.rawValue, forKey: Keys.preferredUnits)
    }
    
    static var getPreferredMeasurementUnit: TemperatureUnit
    {
        if let unit = userDefaults.value(forKey: Keys.preferredUnits) as? String
        {
            return ensureValidMeasurementUnit(unit: unit) // trust, but verify
        }
        
        return ensureValidMeasurementUnit(unit: "")
    }
    
    static var getPreferredLanguage:String
    {
        if let locale = userDefaults.value(forKey: Keys.preferredLanguage) as? String
        {
            return ensureValidLocale(value: locale) // again, trust but verify
        }
        
        if let deviceLanguage = Locale.current.language.languageCode?.identifier
        {
            return ensureValidLocale(value: deviceLanguage)
        }
        
        return "en" // when in doubt, default to English
    }
    
    static func setPreferredLanguage(value:String)
    {
        let cleanLanguageValue = ensureValidLocale(value: value)
        userDefaults.setValue(cleanLanguageValue, forKey: Keys.preferredLanguage)
    }
}
