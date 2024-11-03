//
//  LocationInfo.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

public struct LocationInfo:Codable, Equatable, Identifiable, Hashable
{
    public static func ==(lhs: LocationInfo, rhs: LocationInfo) -> Bool {
        return lhs.name == rhs.name
        && lhs.owLat == rhs.owLat
        && lhs.owLon == rhs.owLon
        && lhs.sunrise_timestamp == rhs.sunrise_timestamp
        && lhs.sunset_timestamp == rhs.sunset_timestamp
        && lhs.country == rhs.country
        && lhs.population == rhs.population
    }
    
    public let id:Int // we can't rely on id, since we can randomly generate a number as an ID, since LocationInfo can be generated locally as well as server-side
    var name:String
    
    let owLat:Double
    let owLon:Double
    let sunrise_timestamp:Int
    let sunset_timestamp:Int
    
    var country:String?
    var population:Int?
    
    // computed values
    var sunriseDate:Date
    {
        return Date(timeIntervalSince1970: TimeInterval(sunrise_timestamp))
    }
    
    var sunsetDate:Date
    {
        return Date(timeIntervalSince1970: TimeInterval(sunset_timestamp))
    }
    
    enum CodingKeys:String, CodingKey
    {
        case name
        case coord
        case sys
        case locationId = "id"
        case localNames = "local_names"
    }
    
    enum CityKeys:String, CodingKey
    {
        case name
        case coord
        case country
        case population
        case sunrise
        case sunset
        case sys
        case cityId = "id"
    }
    
    enum GeoKeys:String, CodingKey
    {
        case name
        case lat
        case lon
        case state
        case country
    }
    
    // only using keys for very popular languages as a test of existence
    enum LocalNamesKeys:String, CodingKey
    {
        case en
        case ascii
        case featureName = "feature_name"
    }
    
    
    enum CoordKeys:String, CodingKey
    {
        case lat
        case lon
    }
    
    enum SysKeys:String, CodingKey
    {
        case sunrise
        case sunset
        case country
    }
    
    public init(id:Int = Int.random(in:1..<10000),
         name:String,
         latitude:Double,
         longitude:Double,
         sunrise:Int = 1,
         sunset:Int = 1,
         country:String? = nil,
         population:Int? = nil)
    {
        // constructor used for temporary LocationInfo
        
        self.name = name
        self.id = id
        self.owLat = latitude
        self.owLon = longitude
        self.sunrise_timestamp = sunrise
        self.sunset_timestamp = sunset
        self.population = population
        self.country = country
    }
    
    static var mock:LocationInfo
    {
        return LocationInfo(id: 5110253,
                            name: "Bronx County",
                            latitude: 40.8301,
                            longitude: -73.9482,
                            sunrise: 1696416899,
                            sunset: 1696458838,
                            country: "US",
                            population: 1385108)
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let sysContainer = try? values.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
        {
            // we're in the current forecast (we should do else if let here if we're going to support other inconsistent calls that use
            // data model like the one defined in Forecast)
            // we're doing 'else' so that we guarantee that the non-optional values are filled
            
            // we're in the multi-hour forecast
            let coordContainer = try values.nestedContainer(keyedBy: CoordKeys.self, forKey: .coord)
            
            self.name = try values.decode(String.self, forKey: .name)
            self.id = try values.decode(Int.self, forKey: .locationId)
            self.sunrise_timestamp = try sysContainer.decode(Int.self, forKey: .sunrise)
            self.sunset_timestamp = try sysContainer.decode(Int.self, forKey: .sunset)
            self.country = try? sysContainer.decode(String.self, forKey: .country)
            
            self.owLat = try coordContainer.decode(Double.self, forKey: .lat)
            self.owLon = try coordContainer.decode(Double.self, forKey: .lon)
        }
        else if let values = try? decoder.container(keyedBy: GeoKeys.self),
                let lan = try? values.decode(Double.self, forKey: .lat)
        {
            let values = try decoder.container(keyedBy: GeoKeys.self)
            var state = try? values.decode(String.self, forKey: .state)
            
            state = (state != nil ) ? (state! + " - ") : nil
            self.id = Int.random(in:1..<10000) // won't matter, these are temporary values
            self.owLat = try values.decode(Double.self, forKey: .lat)
            self.owLon = try values.decode(Double.self, forKey: .lon)
            self.country = try? values.decode(String.self, forKey: .country)
            
            self.name = try values.decode(String.self, forKey: .name)
            self.name = self.name + " - " + (state ?? "")
            self.name = self.name + (self.country ?? "")

            self.sunrise_timestamp = 1 // again, sunrise and sunset won't matter because these are temporary values
            self.sunset_timestamp = 1
        }
        else
        {
            // we're in the multi-hour forecast
            let values = try decoder.container(keyedBy: CityKeys.self)

            let coordContainer = try values.nestedContainer(keyedBy: CoordKeys.self, forKey: .coord)

            self.name = try values.decode(String.self, forKey: .name)
            self.id = try values.decode(Int.self, forKey: .cityId)
            self.sunrise_timestamp = try values.decode(Int.self, forKey: .sunrise)
            self.sunset_timestamp = try values.decode(Int.self, forKey: .sunset)
            self.country = try? values.decode(String.self, forKey: .country)
            self.owLat = try coordContainer.decode(Double.self, forKey: .lat)
            self.owLon = try coordContainer.decode(Double.self, forKey: .lon)
            self.population = try? values.decode(Int.self, forKey: .population)
            
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CityKeys.self)
        
        var coordContainer = container.nestedContainer(keyedBy: CoordKeys.self, forKey: .coord)
        
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .cityId)

        try container.encode(sunrise_timestamp, forKey: .sunrise)
        try container.encode(sunset_timestamp, forKey: .sunset)
        try? container.encode(country, forKey: .country)
        try? container.encode(population, forKey: .population)
        try coordContainer.encode(owLat, forKey: .lat)
        try coordContainer.encode(owLon, forKey: .lon)
        
    }
}
