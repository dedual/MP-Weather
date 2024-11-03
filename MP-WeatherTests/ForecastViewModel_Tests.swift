//
//  ForecastViewModel_Tests.swift
//  MP-WeatherTests
//
//  Created by Nicolas Dedual on 11/3/24.
//
import Foundation

import Testing
@testable import MP_Weather

struct ForecastViewModel_Tests {
    
    var viewModel:ForecastViewModel
    
    init() async throws {
        let mainCoordinatorMock = await MainCoordinator()
        let forecastCoordinatorMock = await ForecastCoordinator(parent: mainCoordinatorMock)
        viewModel = ForecastViewModel(coordinator: forecastCoordinatorMock, weatherAPI: APIManager(), locationManager: LocationManager())
    }
    
    @Test func testRefreshForecastValid() async throws {
        try await confirmation("Test refresh forecast with a given, valid location") { validSearch in
            await viewModel.refreshForecast(locationInfo: TestData.paris.locationInfo)
            
            try #require(viewModel.currentForecast != nil)
            try #require(viewModel.multidayForecast != nil)
            try #require(viewModel.showAlertMessage == nil)
            
            #expect(!viewModel.showAlert)
            #expect(!viewModel.isLoading)
            validSearch.confirm()
        }
    }
    
    @Test func testRefreshForecastInvalid() async throws {
        do{
            await viewModel.refreshForecast(locationInfo: TestData.invalidLocation.locationInfo)
            
            try #require(viewModel.currentForecast == nil)
            try #require(viewModel.multidayForecast == nil)
            try #require(viewModel.showAlertMessage != nil)
            
            #expect(viewModel.showAlert)

        } catch let error {
            print(error)
            Issue.record("Could not testRefreshForecastInvalid: \(error)")
        }
    }
    // Better to test CoreLocation functionality via UIXCTest
    @Test func testHelperFunctions() {
        let text = viewModel.cleanNumberDisplay(105.19785)
        #expect(text == "105.198")
        
        let date = Date(timeIntervalSince1970: 485018100) // 05/15/1985 11:15:00 AM
        let hourText = viewModel.makeHourText(date: date)
        #expect(hourText == "11:15 AM")
        
        let dayText = viewModel.makeDayText(date: date)
        #expect(dayText == "Wednesday")
    }
}
