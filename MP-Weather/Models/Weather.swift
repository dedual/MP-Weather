//
//  Weather.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

public struct Weather: Codable, Equatable
{
    let idWeather:Int
    let main:String
    let description:String
    let iconString:String
    
    var iconURL:URL?
    {
        return URL(string: "https://openweathermap.org/img/wn/\(iconString).png")
    }
    
    var icon2XURL:URL?
    {
        return URL(string: "https://openweathermap.org/img/wn/\(iconString)@2x.png")
    }
    
    enum CodingKeys:String, CodingKey
    {
        case idWeather = "id"
        case mainWeather = "main"
        case descriptionWeather = "description"
        case iconString = "icon"
    }
    
    public init (idWeather:Int, main:String, description:String, iconString:String) {
        self.idWeather = idWeather
        self.main = main
        self.description = description
        self.iconString = iconString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idWeather = try container.decode(Int.self, forKey: .idWeather)
        self.main = try container.decode(String.self, forKey: .mainWeather)
        self.description = try container.decode(String.self, forKey: .descriptionWeather)
        self.iconString = try container.decode(String.self, forKey: .iconString)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(idWeather, forKey: .idWeather)
        try container.encode(main, forKey: .mainWeather)
        try container.encode(description, forKey: .descriptionWeather)
        try container.encode(iconString, forKey: .iconString)

    }
}

