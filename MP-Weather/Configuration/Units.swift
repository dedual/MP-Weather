//
//  Units.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

enum TemperatureUnit:String, Equatable
{
    case kelvin = "standard"
    case metric = "metric"
    case imperial = "imperial"
    
    static var all:[TemperatureUnit]
    {
        return [TemperatureUnit.kelvin, TemperatureUnit.metric, TemperatureUnit.imperial]
    }
    static var allRaw:[String]
    {
        return [TemperatureUnit.kelvin.rawValue, TemperatureUnit.metric.rawValue, TemperatureUnit.imperial.rawValue]
    }
    var unitText:String
    {
        switch self {
            
        case .kelvin:
            return "°K"
        case .metric:
            return "°C"
        case .imperial:
            return "°F"
        }
    }
    
    var label:String
    {
        switch self {
            
        case .kelvin:
            return "Kelvin"
        case .metric:
            return "Celsius"
        case .imperial:
            return "Fahrenheit"
        }
    }
    
    var unitForBackend:String
    {
        return self.rawValue
    }
    
    static func validUnit(rawString:String) -> Bool
    {
        return TemperatureUnit.allRaw.contains(rawString)
    }
}
