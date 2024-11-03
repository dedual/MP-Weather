//
//  NetworkingCostants.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

struct NetworkingConstants
{
    struct OpenWeather
    {
        static let host = Environment.openWeatherBaseURL
        static let base = "data/"
        static let version = "2.5/"
        static let geo = "geo/1.0/" // hard coding version here because it's the only one that's different (or so it seems).
        // different api paths we currently support
        static let currentWeather = "weather"
        static let forecast = "forecast"
        static let geocode = "direct"
        
        static let staleness_timelapse_seconds:Double = 600.0 // 10 minutes, though for free accounts the documentation states that data can be stale for up to 3 hours (https://openweathermap.org/full-price#current)
    }
}

public enum HTTPMethod:String
{
    case GET
    case POST
    case PUT
    case DELETE
}

extension Encodable {
    func encode() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }
}

extension Dictionary where Key == String, Value == String {
    func urlEncode() -> Data? {
        do {
            var queryItems: [URLQueryItem] = []
            for (key, value) in self {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            var components = URLComponents()
            components.queryItems = queryItems
            return components.query?.data(using: .utf8)
        }
    }
}

enum LocationError: Error, Equatable
{
    case denied(_ error:String?)
    case unknown(_ error:String?)
    case awaitingPermission
    var customMessage: String
    {
        switch self
        {
        case .awaitingPermission:
            return "Error: Awaiting user permission"
        case .denied(let error):
            return "Error: Cannot retrieve location.\n\(error != nil ? "Error: \(error!)" :"")"
        case .unknown(let error):
            return "Error: Cannot retrieve location.\n\(error != nil ? "Error: \(error!)" :"")"
        @unknown default: // may add other errors. Keep in case
            return "Error: Cannot retrieve location"
        }
    }
}

// TODO: Need to redo the below
enum RequestError: Error { // redo
    case badURL(_ error: String?)
    case invalidURL
    case cannotDecode
    case apiError(code: String, error: String?)
    case invalidJSON
    case unauthorized(code: Int?)
    case badRequest(code: Int)
    case serverError(code: Int)
    case noResponse
    case unableToParseData(_ error: String?)
    case offline
    case unknown(error: String?)

    var customMessage: String {
        switch self {
        case .cannotDecode:
            return "Error: Cannot decode"
        case .unauthorized(let code):
            return "Error: Session expired. \(code != nil ? "Code error \(code!)" :"")"
        case .unknown(let error):
            return "Error: An unknown error has occured. " + (error ?? "")
        case .badURL(let error):
            return "Error: A Bad URL was detected. \(error != nil ? "Error: \(error!)" :"")"
        case .invalidURL:
            return "Error: invalid URL"
        case .apiError(code: let code, error: let error):
            return "Error: API error code \(code). \(error != nil ? "Error: \(error!)" :"")"
        case .invalidJSON:
            return "Error: Invalid JSON detected"
        case .badRequest(code: let code):
            return "Error: Bad request sent. Code \(code)"
        case .serverError(code: let code):
            return "Server error. Code \(code)"
        case .noResponse:
            return "Error: No response from server"
        case .unableToParseData(let error):
            return "Error, unable to parse data. \(error != nil ? "Error: \(error!)" :"")"
        case .offline:
            return "Error. Device is offline"
        }
    }
}

