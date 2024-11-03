//
//  MP_WeatherTests.swift
//  MP-WeatherTests
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import Testing
@testable import MP_Weather

struct MP_WeatherTests {
    
    enum Error: Swift.Error {
        case cannotOpenJSON
        case locationMismatch
        case invalidDataProcessed
    }
    
    var weatherAPI:APIManager
    
    init() async throws {
        weatherAPI = APIManager()
    }
    
    // MARK: - Search tests
    
    @Test func testValidSearch() async throws
    {
        try await confirmation("Perform network request with given location") { validSearch in
            do {
                let data = try await weatherAPI.getTempLocationsInfoFromQuery(address: TestData.harlem.locationAddress)
                print("Data received: \(data)")
                //data == TestData.harlem.locationInfo
                guard let location = data.first else {
                    throw Error.locationMismatch
                }
                #expect(location == TestData.harlem.locationInfo)
                validSearch.confirm()
            } catch let error {
                print("⚠️ \(error)")
                throw error
            }
        }
    }
    
    @Test func testInvalidSearch() async throws
    {
        try await confirmation("Perform network request with an incomplete location") { invalidSearch in
            do {
                let data = try await weatherAPI.getTempLocationsInfoFromQuery(address: TestData.invalidLocation.locationAddress)
                if data.count == 0 {
                    print("No location found")
                    invalidSearch.confirm()
                }
                else {
                    print("Data received: \(data)")
                    throw Error.invalidDataProcessed
                }

            } catch let error {
                print("⚠️ \(error)")
                
                throw error
            }
        }
    }
    // MARK: - Current Forecast tests
    @Test func testCurrentForecastRequestByLatLon() async throws {
        
        try await confirmation("Perform weather forecast request with given location") { validSearch in
            do {
                let data = try await weatherAPI.currentForecast(latitude: TestData.paris.location.latitude, longitude: TestData.paris.location.longitude)
                print("Data received: \(data)")
                validSearch.confirm()
            } catch let error {
                print("⚠️ \(error)")
                throw error
            }
        }
    }
    
    @Test func testCurrentForecastRequestByAddressNoGeocoding() async throws {
        
        try await confirmation("Perform network request with given text address, no geocoding via Apple") { validSearch in
            do {
                let data = try await weatherAPI.sendRequest(endpoint: .currentWithQuery(query: TestData.paris.locationAddress), responseModel: CurrentForecast.self)
                print("Data received: \(data)")
                validSearch.confirm()
            } catch let error {
                print("⚠️ \(error)")
                throw error
            }
        }
    }
    
    @Test func testCurrentForecastRequestByAddressInvalidData() async throws {
        try await confirmation("Perform network request with given text address, but returns error") { invalidSearch in
            do {
                let data = try await weatherAPI.currentForecast(address: TestData.invalidLocation.locationAddress)
                print("Data received: \(data)")
                throw Error.invalidDataProcessed
            } catch let error {
                print("⚠️ \(error)")
                
                invalidSearch.confirm()
                //throw error
            }
        }
    }
    
    @Test func testCurrentForecastRequestByAddressInvalidDataNoGeocoding() async throws {
        try await confirmation("Perform network request with given text address, no geocoding via Apple, but returns error") { invalidSearch in
            do {
                let data = try await weatherAPI.sendRequest(endpoint: .currentWithQuery(query: TestData.invalidLocation.locationAddress), responseModel:CurrentForecast.self)
                print("Data received: \(data)")
                throw Error.invalidDataProcessed
            }
            catch let error {
                print("⚠️ \(error)")
                invalidSearch.confirm()
            }
        }
    }
    
    // MARK: - Multiday forecast test functions
    
    @Test func testMultidayForecastRequestByLatLon() async throws {
        try await confirmation("Perform network request with given location") { validSearch in
            do {
                let data = try await weatherAPI.multidayForecast(latitude: TestData.newyork.location.latitude, longitude: TestData.newyork.location.longitude)
                print("Data received: \(data)")
                validSearch.confirm()
            }
            catch let error {
                print("⚠️ \(error)")
                throw error
            }
        }
    }

    @Test func testMultidayForecastRequestByAddressNoGeocoding() async throws {
        try await confirmation("Perform network request with given text address, no geocoding via Apple") { validSearch in
            do {
                if let validAddress = weatherAPI.returnValidAddressQueryString(TestData.newyork.locationAddress) {
                    let data = try await weatherAPI.sendRequest(endpoint: .forecastWithQuery(query: validAddress), responseModel:MultiDayForecast.self)
                    print("Data received: \(data)")
                }
                else{
                    let data = try await weatherAPI.sendRequest(endpoint: .forecastWithQuery(query: TestData.newyork.locationAddress), responseModel:MultiDayForecast.self)
                    print("Data received: \(data)")
                }
                validSearch.confirm()
            }
            catch let error {
                print("⚠️ \(error)")
                throw error
            }
        }
    }
    
    @Test func testMultidayForecastRequestByAddressInvalidData() async throws {
        try await confirmation("Perform network request with given text address, no geocoding via Apple") { invalidSearch in
            do {
                let data = try await weatherAPI.multidayForecast(latitude: TestData.invalidLocation.location.latitude, longitude: TestData.invalidLocation.location.longitude)
                print("Data received: \(data)")
                throw Error.invalidDataProcessed
            }
            catch let error {
                print("⚠️ \(error)")
                invalidSearch.confirm()
            }
        }
    }
    
    @Test func testMultidayForecastRequestByAddressInvalidDataNoGeocoding() async throws {
        try await confirmation("Perform network request with given text address, no geocoding via Apple, but returns error") { invalidSearch in
            do {
                let data = try await weatherAPI.sendRequest(endpoint: .currentWithQuery(query: TestData.invalidLocation.locationAddress), responseModel:MultiDayForecast.self)
                print("Data received: \(data)")
                throw Error.invalidDataProcessed

            } catch let error {
                print("⚠️ \(error)")
                invalidSearch.confirm()
            }
        }
    }
}
