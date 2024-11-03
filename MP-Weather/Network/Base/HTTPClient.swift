//
//  HTTPClient.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

protocol HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Router, responseModel: T.Type) async throws -> T
}

/// Usage let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
extension HTTPClient {
    
    func sendRequest<T: Decodable>(
        endpoint: Router,
        responseModel: T.Type
    ) async throws -> T {
        
        var request = URLComponents(string: endpoint.url)!
        let timeOut:Float = 15.0
        
        if let parameters = endpoint.queryItems, parameters.count > 0 {
            request.queryItems = parameters
        }
        
        guard let url = request.url else { throw RequestError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers ?? [:]
        urlRequest.httpBody = endpoint.body
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = TimeInterval(timeOut)
        
        let session = URLSession(configuration: sessionConfig)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            switch response.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let decodedResponse = try decoder.decode(responseModel, from: data)
                    return decodedResponse

                } catch let DecodingError.dataCorrupted(context) {
                        throw RequestError.cannotDecode
                    } catch let DecodingError.keyNotFound(key, context) {
                        throw RequestError.unableToParseData("Key '\(key)' not found. \(context.debugDescription). codingPath: \(context.codingPath)")
                    } catch let DecodingError.valueNotFound(value, context) {
                        throw RequestError.unableToParseData("Value '\(value)' not found: \(context.debugDescription). codingPath: \(context.codingPath)")
                    } catch let DecodingError.typeMismatch(type, context)  {
                        throw RequestError.unableToParseData("Type '\(type)' mismatch: \(context.debugDescription). codingPath: \(context.codingPath)")
                    } catch {
                        do{
                            let errorResponse = try decoder.decode(OpenWeatherError.self, from: data)
                            throw RequestError.apiError(code: errorResponse.code, error: errorResponse.message)
                        }
                        catch let error
                        {
                            throw RequestError.unknown(error: error.localizedDescription)
                        }
                    }
                
            case 401:
                throw RequestError.unauthorized(code: 401)
            case 404:
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let errorResponse = try? decoder.decode(OpenWeatherError.self, from: data)
                {
                    throw RequestError.apiError(code: errorResponse.code, error: errorResponse.message)
                }
                
                throw RequestError.badURL("404 Error. URL Not Found")

            default:
            
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let errorResponse = try? decoder.decode(OpenWeatherError.self, from: data)
                {
                    throw RequestError.apiError(code: errorResponse.code, error: errorResponse.message)
                }
                
                throw RequestError.unknown(error: "Unknown error has occured")
            }
        }
        catch URLError.Code.notConnectedToInternet {
            throw RequestError.offline
        }
    }
}

