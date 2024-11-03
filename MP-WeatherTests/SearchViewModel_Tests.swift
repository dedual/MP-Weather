//
//  SearchViewModel_Tests.swift
//  MP-WeatherTests
//
//  Created by Nicolas Dedual on 11/3/24.
//

import Foundation

import Testing
@testable import MP_Weather

struct SearchViewModel_Tests {

    var viewModel:SearchViewModel

    init() async throws {
        let mainCoordinatorMock = await MainCoordinator()
        let searchCoordinatorMock = await SearchCoordinator(parent: mainCoordinatorMock)
        viewModel = SearchViewModel(coordinator: searchCoordinatorMock, weatherAPI: APIManager(), locationManager: LocationManager())
    }
    
    
    
    @Test(arguments: ["Einsiedeln", "Boston", "Sacramento, CA, US", "Paris, France", "Tahiti"])
    func testValidSearch(search:String) async throws {
        try await confirmation("Test refresh forecast with a given, valid location") { validSearch in
            await viewModel.runSearch(searchLocation: search)
            
            #expect(viewModel.retrievedLocations.count > 0)
            
            #expect(!viewModel.showAlert)
            try #require(viewModel.showAlertMessage == nil)
            validSearch.confirm()
        }
    }

}
