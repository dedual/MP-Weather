//
//  TestData.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/3/24.
//

import Foundation
import CoreLocation
import MP_Weather

enum TestData
{
    case paris
    case newyork
    case harlem
    case veniceUncertain
    case invalidLocation

    var location:CLLocationCoordinate2D
    {
        switch self {
        case .paris:
            return CLLocationCoordinate2D(latitude: 48.858677079685634, longitude: 2.2944851172211354)
        case .newyork:
            return CLLocationCoordinate2D(latitude: 40.760618131634374, longitude: -73.98003200771446)
        case .harlem:
            return CLLocationCoordinate2D(latitude: 40.809964731782834, longitude: -73.95010733420638)
        case .invalidLocation:
            return CLLocationCoordinate2D(latitude: -120.0, longitude: 270)
        case .veniceUncertain:
            return CLLocationCoordinate2D()
        }
    }
    
    var locationAddress:String
    {
        switch self {
        case .paris:
            return "Champ de Mars, 5 Av. Anatole France, 75007 Paris, France"
        case .newyork:
            return "1260 6th Ave, New York, NY 10020"
        case .harlem:
            return "253 W 125th St, New York, NY 10027"
        case .invalidLocation:
            return "Gobbledygook!"
        case .veniceUncertain:
            return "Venice"
        }
    }
    
    var locationInfo:LocationInfo {
        switch self {
            
        case .paris:
            return LocationInfo(name: "Palais-Royal", latitude: 48.8587, longitude: 2.2945, sunrise: 1730616078, sunset: 1730651244, country: "FR")
        case .newyork:
            return LocationInfo(name: "", latitude: 40.760618131634374, longitude:  -73.98003200771446)
        case .harlem:
            return LocationInfo(id: 5595,
                                name: "New York - New York - US",
                                latitude: 40.7127281,
                                longitude: -74.0060152,
                                sunrise: 1,
                                sunset: 1,
                                country: "US",
                                population: nil)
        case .veniceUncertain:
            return LocationInfo(name: "", latitude: 0, longitude: 0)
        case .invalidLocation:
            return LocationInfo(name: "Invalid", latitude:  -120.0, longitude: 270)
        }
    }
}
