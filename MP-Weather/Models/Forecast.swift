//
//  Forecast.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

public struct Forecast:Codable, Equatable, Identifiable
{
    public static func ==(lhs: Forecast, rhs: Forecast) -> Bool {
        return lhs.coreMeasurements == rhs.coreMeasurements
        && lhs.weather == rhs.weather
        && lhs.visibilityInMeters == rhs.visibilityInMeters
        && lhs.visibilityPercentage == rhs.visibilityPercentage
        && lhs.windSpeed == rhs.windSpeed
        && lhs.windDirection == rhs.windDirection
        && lhs.windGust == rhs.windGust
        && lhs.cloudiness == rhs.cloudiness
        && lhs.rain1H == rhs.rain1H
        && lhs.rain3H == rhs.rain3H
        && lhs.snow1H == rhs.snow1H
        && lhs.snow3H == rhs.snow3H
        && lhs.dt_timestamp == rhs.dt_timestamp
        && lhs.probPrecipitation == rhs.probPrecipitation
    }
    
    let coreMeasurements:CoreMeasurements
    let weather:[Weather]
    public let id = UUID()
   // let base: String
    let visibilityInMeters:Int
    let visibilityPercentage:Double
    
    let windSpeed:Double
    let windDirection:Int // meterological degrees
    let windGust:Double?
    
    let cloudiness:Int // reported as percentage (but backend has it as an Int?. Weird)
    
    var rain1H:Double? // not necessarily available
    var rain3H:Double? // not necessarily available
    
    var snow1H:Double? // not necessarily available
    var snow3H:Double? // not necessarily available
        
    let dt_timestamp:Int // also used for forecast time
    
    var probPrecipitation:Double? // used in multi-day forecast
    
    // computed values
    var dateForecasted:Date
    {
        return Date(timeIntervalSince1970: TimeInterval(dt_timestamp))
    }
    
    enum ContainerKeys:String, CodingKey
    {
        case weather = "weather"
        case main
        case wind
        case clouds
        case rain
        case snow
        //case base
        case visibility
        case probPrecipitation = "pop"
        case dt
        case forecastID = "id"
        case timezone // not used right now
        case name
    }
    
    enum CodingKeys:String, CodingKey
    {
        case speed
        case deg
        case gust
        case all
        case pod
        case oneH = "1h"
        case threeH = "3h"
    }
    
    public init(coreMeasurements:CoreMeasurements, weather:[Weather],
                visibilityInMeters:Int, visibilityPercentage:Double,
                windSpeed:Double, windDirection:Int, windGust:Double? = nil,
                cloudiness:Int, rain1H:Double? = nil, rain3H:Double? = nil,
                snow1H:Double? = nil, snow3H:Double? = nil, dt_timestamp:Int,
                probPrecipitation:Double? = nil) {
        
        self.coreMeasurements = coreMeasurements
        self.weather = weather
       // let base: String
        self.visibilityInMeters = visibilityInMeters
        self.visibilityPercentage = visibilityPercentage
        
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.windGust = windGust
        
        self.cloudiness = cloudiness
        
        self.rain1H = rain1H
        self.rain3H = rain3H
        
        self.snow1H = snow1H
        self.snow3H = snow3H
            
        self.dt_timestamp = dt_timestamp
        
        self.probPrecipitation = probPrecipitation
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContainerKeys.self)
        let wind = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .wind)
        let clouds = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .clouds)
        let rain = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .rain)
        let snow = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .snow)
        
        self.weather = try values.decode([Weather].self, forKey: .weather)
        self.coreMeasurements = try values.decode(CoreMeasurements.self, forKey: .main)
        
        //self.base = try values.decode(String.self, forKey: .base)
        
        self.visibilityInMeters = try values.decode(Int.self, forKey: .visibility)
        self.visibilityPercentage = Double(self.visibilityInMeters) / 10000.0
        
        self.probPrecipitation = try? values.decodeIfPresent(Double.self, forKey: .probPrecipitation)
       
        self.windSpeed = try wind.decode(Double.self, forKey: .speed)
        self.windGust = try? wind.decodeIfPresent(Double.self, forKey: .gust)
        self.windDirection = try wind.decode(Int.self, forKey: .deg)
        
        self.cloudiness = try clouds.decode(Int.self, forKey: .all)
        
        self.rain1H = try? rain?.decodeIfPresent(Double.self, forKey: .oneH)
        self.rain3H = try? rain?.decodeIfPresent(Double.self, forKey: .threeH)
        
        self.snow1H = try? snow?.decodeIfPresent(Double.self, forKey: .oneH)
        self.snow3H = try? snow?.decodeIfPresent(Double.self, forKey: .threeH)
        
        self.dt_timestamp = try values.decode(Int.self, forKey: .dt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var wind = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .wind)
        var clouds = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .clouds)
        var rain = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rain)
        var snow = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snow)
        
        try container.encode(weather, forKey: .weather)
        try container.encode(coreMeasurements, forKey: .main)

       // try container.encode(base, forKey: .base)
        try container.encode(visibilityInMeters, forKey: .visibility)
        
        try wind.encode(windSpeed, forKey: .speed)
        try? wind.encodeIfPresent(windGust, forKey: .gust)
        try wind.encode(windDirection, forKey: .deg)

        try clouds.encode(cloudiness, forKey: .all)
        
        try? rain.encodeIfPresent(rain1H, forKey: .oneH)
        try? rain.encodeIfPresent(rain3H, forKey: .threeH)

        try? snow.encodeIfPresent(snow1H, forKey: .oneH)
        try? snow.encodeIfPresent(snow3H, forKey: .threeH)

        try container.encode(dt_timestamp, forKey: .dt)
    }
}
