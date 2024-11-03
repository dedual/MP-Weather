//
//  Router.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

enum Router:Equatable
{
    case current(lat:Double, lon:Double)
    case forecast(lat:Double, lon:Double)
    case currentWithQuery(query:String)
    case forecastWithQuery(query:String)
    case geocode(query:String)
    // note: don't use OpenWeather's geocoding service. Apple provides a more accurate one that's free to iOS developers
    
    var url:String
    {
        switch self
        {
        case .current, .currentWithQuery:
            return NetworkingConstants.OpenWeather.host +
            NetworkingConstants.OpenWeather.base +
            NetworkingConstants.OpenWeather.version +
            NetworkingConstants.OpenWeather.currentWeather
            
            
        case .forecast, .forecastWithQuery:
            return NetworkingConstants.OpenWeather.host +
            NetworkingConstants.OpenWeather.base +
            NetworkingConstants.OpenWeather.version +
            NetworkingConstants.OpenWeather.forecast
            
        case .geocode:
            return NetworkingConstants.OpenWeather.host +
            NetworkingConstants.OpenWeather.geo +
            NetworkingConstants.OpenWeather.geocode
        }
    }
    
    var headers:[String:String]?
    {
        switch self
        {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var body:Data?
    {
        switch self
        {
        default:
            return nil
        }
    }
    
    var queryItems:[URLQueryItem]?
    {
        switch self
        {
        case .current(let lat, let lon):
            return [
                URLQueryItem(name:"lat", value: "\(lat)"),
                URLQueryItem(name:"lon", value: "\(lon)"),
                URLQueryItem(name:"appid", value: Environment.openWeatherAPIKey),
                URLQueryItem(name:"units", value: UserPreferences.getPreferredMeasurementUnit.rawValue),
                URLQueryItem(name:"lang", value: UserPreferences.getPreferredLanguage),
            ]
        case .currentWithQuery(let query):
            return [
                URLQueryItem(name:"q", value: "\(query)"),
                URLQueryItem(name:"appid", value: Environment.openWeatherAPIKey),
                URLQueryItem(name:"units", value: UserPreferences.getPreferredMeasurementUnit.rawValue),
                URLQueryItem(name:"lang", value: UserPreferences.getPreferredLanguage),
            ]
        case .forecast(let lat, let lon):
            return [
                URLQueryItem(name:"lat", value: "\(lat)"),
                URLQueryItem(name:"lon", value: "\(lon)"),
                URLQueryItem(name:"appid", value: Environment.openWeatherAPIKey),
                URLQueryItem(name:"units", value: UserPreferences.getPreferredMeasurementUnit.rawValue),
                URLQueryItem(name:"lang", value: UserPreferences.getPreferredLanguage),
            ]
        case .forecastWithQuery(let query):
            return [
                URLQueryItem(name:"q", value: "\(query)"),
                URLQueryItem(name:"appid", value: Environment.openWeatherAPIKey),
                URLQueryItem(name:"units", value: UserPreferences.getPreferredMeasurementUnit.rawValue),
                URLQueryItem(name:"lang", value: UserPreferences.getPreferredLanguage),
            ]
        case .geocode(let query):
            return [
                URLQueryItem(name:"q", value: "\(query)"),
                URLQueryItem(name:"appid", value: Environment.openWeatherAPIKey),
                URLQueryItem(name:"limit", value: "6"), // yes, hard coding for now.
            ]
        }
    }
    
    var httpMethod:HTTPMethod
    {
        switch self
        {
        default:
            return .GET
        }
    }
    
    func buildURLRequest() -> URLRequest? {
        
        var urlComponents = URLComponents(string: url)
        if let parameters = queryItems, parameters.count > 0
        {
            urlComponents?.queryItems = parameters
        }
        
        guard let finalURL = urlComponents?.url else { return nil}
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers ?? [:]
        urlRequest.httpBody = body

        return urlRequest
    }
}
