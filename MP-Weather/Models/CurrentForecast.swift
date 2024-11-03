//
//  CurrentForecast.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

public struct CurrentForecast:Codable, Equatable
{
    let forecast:Forecast
    let locationInfo:LocationInfo
    
    public init(forecast:Forecast, locationInfo:LocationInfo) {
        self.forecast = forecast
        self.locationInfo = locationInfo
    }
    
    public init(from decoder: Decoder) throws {
        
        let forecastContainer = try decoder.singleValueContainer()
        self.forecast = try forecastContainer.decode(Forecast.self)
        self.locationInfo = try forecastContainer.decode(LocationInfo.self)
    }
    
    static var mock:CurrentForecast
    {
        if let url = Bundle.main.url(forResource: "TestCurrentForecast", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(CurrentForecast.self, from: data)
                    return jsonData
                } catch {
                    print("error:\(error)")
                    fatalError("Error: \(error)")
                }
            }
        else {
            fatalError("Could not open test json file")
        }
    }
}
