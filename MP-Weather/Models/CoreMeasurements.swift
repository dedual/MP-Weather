//
//  CoreMeasurements.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

public struct CoreMeasurements:Codable, Equatable
{
    let temperature:Double
    let feelsLike:Double
    let minTemperature:Double
    let maxTemperature:Double
    let pressure:Int
    let humidity:Int
    let seaLevel:Int?
    let groundLevel:Int?
    
    enum CodingKeys:String, CodingKey
    {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minTemperature = "temp_min"
        case maxTemperature = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
    
    public init(temperature:Double,
                feelsLike:Double,
                minTemperature:Double,
                maxTemperature:Double,
                pressure:Int,
                humidity:Int,
                seaLevel:Int? = nil,
                groundLevel:Int? = nil) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.pressure = pressure
        self.humidity = humidity
        self.seaLevel = seaLevel
        self.groundLevel = groundLevel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.feelsLike = try container.decode(Double.self, forKey: .feelsLike)
        self.minTemperature = try container.decode(Double.self, forKey: .minTemperature)
        self.maxTemperature = try container.decode(Double.self, forKey: .maxTemperature)
        self.pressure = try container.decode(Int.self, forKey: .pressure)
        self.humidity = try container.decode(Int.self, forKey: .humidity)
        self.groundLevel = try? container.decode(Int.self, forKey: .groundLevel)
        self.seaLevel = try? container.decode(Int.self, forKey: .seaLevel)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.temperature, forKey: .temperature)
        try container.encode(self.feelsLike, forKey: .feelsLike)
        try container.encode(self.minTemperature, forKey: .minTemperature)
        try container.encode(self.maxTemperature, forKey: .maxTemperature)
        try container.encode(self.pressure, forKey: .pressure)
        try container.encode(self.humidity, forKey: .humidity)
        try? container.encode(self.seaLevel, forKey: .seaLevel)
        try? container.encode(self.groundLevel, forKey: .groundLevel)
    }
}
