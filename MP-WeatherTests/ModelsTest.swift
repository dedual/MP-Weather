//
//  ModelsTest.swift
//  MP-WeatherTests
//
//  Created by Nicolas Dedual on 11/3/24.
//

import Foundation
import Testing
@testable import MP_Weather

struct ModelsTest {
    
    enum ModelError: Swift.Error {
        case cannotOpenJSON
        case cannotParse
        case weatherPredictionMismatch
        case handCodedMismatch
    }

    // MARK: - Model tests
    @Test func testCurrentForecast() throws {
        guard let url = Bundle.main.url(forResource: "TestCurrentForecast", withExtension: "json") else {
            Issue.record("Missing file TestCurrentForecast.json")
            throw ModelError.cannotOpenJSON
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(CurrentForecast.self, from: data)
            
            // Test LocationInfo data object
            let handCodedLocationInfo = LocationInfo(name: "New York", latitude: 40.7143, longitude: -74.006, sunrise: 1696330449, sunset: 1696372554, country: "US")
            
            let locationInfo = jsonData.locationInfo
            
            #expect(locationInfo.name == handCodedLocationInfo.name)
            #expect(locationInfo.owLat == handCodedLocationInfo.owLat)
            #expect(locationInfo.owLon == handCodedLocationInfo.owLon)
            #expect(locationInfo.sunrise_timestamp == handCodedLocationInfo.sunrise_timestamp)
            #expect(locationInfo.sunset_timestamp == handCodedLocationInfo.sunset_timestamp)
            
            let country = try #require(locationInfo.country)
            let handCodedCountry = try #require(locationInfo.country)
            #expect(country == handCodedCountry)

            // Test Forecast data object
            #expect(jsonData.forecast.weather.count == 1)
            guard let weather = jsonData.forecast.weather.first else {
                Issue.record("There's no weather forecast present. That's wrong.")
                throw ModelError.weatherPredictionMismatch
            }
            // Start with weather

            let handCodedWeather = Weather(idWeather: 800, main: "Clear", description: "clear sky", iconString: "01n")
            #expect(handCodedWeather.idWeather == weather.idWeather)
            #expect(handCodedWeather.main == weather.main)
            #expect(handCodedWeather.description == weather.description)
            #expect(handCodedWeather.iconString == weather.iconString)

            // Then with Core Measurements
            let coreMeasurements = jsonData.forecast.coreMeasurements
            let handCodedCoreMeasurements = CoreMeasurements(temperature: 69.01, feelsLike: 69.31, minTemperature: 63.19, maxTemperature: 71.98, pressure: 1021, humidity: 79)
            #expect(handCodedCoreMeasurements.temperature == coreMeasurements.temperature)
            #expect(handCodedCoreMeasurements.feelsLike == coreMeasurements.feelsLike)
            #expect(handCodedCoreMeasurements.minTemperature == coreMeasurements.minTemperature)
            #expect(handCodedCoreMeasurements.maxTemperature == coreMeasurements.maxTemperature)
            #expect(handCodedCoreMeasurements.pressure == coreMeasurements.pressure)
            #expect(handCodedCoreMeasurements.humidity == coreMeasurements.humidity)

            // Then visibility
            #expect(jsonData.forecast.visibilityInMeters == 10000)
            
            // then Wind
            #expect(jsonData.forecast.windSpeed == 4.61)
            #expect(jsonData.forecast.windDirection == 180)
            
            #expect(jsonData.forecast.cloudiness == 0)
           
        } catch {
            Issue.record("Could not parse CurrentForecast: \(error)")
            throw ModelError.cannotParse
        }
    }
        
    @Test func testMultiDayForecast() throws {
        guard let url =  Bundle.main.url(forResource: "TestFutureForecast", withExtension: "json")  else {
            Issue.record("Missing file TestFutureForecast.json")
            throw ModelError.cannotOpenJSON
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(MultiDayForecast.self, from: data)
            
            let handCodedLocationInfo = LocationInfo(id: 2660925, name: "Einsiedeln", latitude: 47.1167, longitude: 8.75, sunrise: 1696397223, sunset: 1696438827, country: "CH", population: 13148)
                        
            let handCodedForecasts = [
                Forecast(coreMeasurements: CoreMeasurements(temperature: 50.38, feelsLike: 49.73, minTemperature: 49.32, maxTemperature: 50.38, pressure: 1030, humidity: 98, seaLevel:1030, groundLevel: 914), weather: [Weather(idWeather: 804, main: "Clouds", description: "overcast clouds", iconString: "04n")], visibilityInMeters: 10000, visibilityPercentage: 1.0, windSpeed: 1.77, windDirection: 360, windGust:1.92, cloudiness: 85, dt_timestamp: 1696388400, probPrecipitation: 0.0),
                Forecast(coreMeasurements: CoreMeasurements(temperature: 49.87, feelsLike: 49.87, minTemperature: 48.87, maxTemperature: 49.87, pressure: 1030, humidity: 97, seaLevel:1030, groundLevel: 915), weather: [Weather(idWeather: 803, main: "Clouds", description: "broken clouds", iconString: "04d")], visibilityInMeters: 10000, visibilityPercentage: 1.0, windSpeed: 1.63, windDirection: 30, windGust:1.77, cloudiness: 84, dt_timestamp: 1696399200, probPrecipitation: 0.0),
                Forecast(coreMeasurements: CoreMeasurements(temperature: 53.06, feelsLike: 52.16, minTemperature: 53.06, maxTemperature: 54.41, pressure: 1029, humidity: 87, seaLevel:1029, groundLevel: 916), weather: [Weather(idWeather: 804, main: "Clouds", description: "overcast clouds", iconString: "04d")], visibilityInMeters: 10000, visibilityPercentage: 1.0, windSpeed: 2.46, windDirection: 1, windGust:2.37, cloudiness: 88, dt_timestamp: 1696410000, probPrecipitation: 0.0),
                //
                Forecast(coreMeasurements: CoreMeasurements(temperature: 59.99, feelsLike: 58.84, minTemperature: 59.99, maxTemperature: 59.99, pressure: 1027, humidity: 67, seaLevel:1027, groundLevel: 915), weather: [Weather(idWeather: 803, main: "Clouds", description: "broken clouds", iconString: "04d")], visibilityInMeters: 10000, visibilityPercentage: 1.0, windSpeed: 5.44, windDirection: 338, windGust:3.44, cloudiness: 70, dt_timestamp: 1696420800, probPrecipitation: 0.0),
               
            ]
            
            let handCodedMultidayForecast = MultiDayForecast.init(forecasts: handCodedForecasts, locationInfo: handCodedLocationInfo)
            
            let locationInfo = jsonData.locationInfo
            
            #expect(locationInfo.name == handCodedLocationInfo.name)
            #expect(locationInfo.owLat == handCodedLocationInfo.owLat)
            #expect(locationInfo.owLon == handCodedLocationInfo.owLon)
            #expect(locationInfo.sunrise_timestamp == handCodedLocationInfo.sunrise_timestamp)
            #expect(locationInfo.sunset_timestamp == handCodedLocationInfo.sunset_timestamp)
            
            let country = try #require(locationInfo.country)
            let handCodedCountry = try #require(locationInfo.country)
            #expect(country == handCodedCountry)
            
            #expect(handCodedMultidayForecast.forecasts.count == jsonData.forecasts.count)
            
            guard handCodedMultidayForecast.forecasts.count == jsonData.forecasts.count else {
                Issue.record("Hand coded forecasts is not the same as the json data")
                throw ModelError.handCodedMismatch
            }
            
            for i in 0..<jsonData.forecasts.count {
                let handCodedForecast = handCodedMultidayForecast.forecasts[i]
                let forecast = jsonData.forecasts[i]
                #expect(handCodedForecast == forecast)
            }
            
        } catch {
            Issue.record("Could not parse MultiDayForecast: \(error)")
            throw ModelError.cannotParse
        }
    }
}
