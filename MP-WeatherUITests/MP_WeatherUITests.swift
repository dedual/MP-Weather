//
//  MP_WeatherUITests.swift
//  MP-WeatherUITests
//
//  Created by Nicolas Dedual on 11/2/24.
//

import XCTest
import SwiftUI

final class MP_WeatherUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    
    func testCoreLocationForecastRetrieval() {
        
        let app = XCUIApplication()
        app.tabBars["Tab Bar"].buttons["Locations"].tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Get your local weather report"]/*[[".cells.buttons[\"Get your local weather report\"]",".buttons[\"Get your local weather report\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let coreLocationAlert = app.alerts["Allow “MP-Weather” to use your location?"]
        if coreLocationAlert.exists {
            coreLocationAlert.scrollViews.otherElements.buttons["Allow While Using App"].tap()
        }
    }

    func testCoreLocationInitialPermissionRequest() {
        let button = app.buttons["Use your device's location?"]
        if button.exists {
            button.tap()
            let coreLocationAlert = app.alerts["Allow “MP-Weather” to use your location?"]
            if coreLocationAlert.exists {
                coreLocationAlert.scrollViews.otherElements.buttons["Allow While Using App"].tap()
            }
        }
    }
    
    func testUISearch() {
        
        let app = XCUIApplication()
        app.tabBars["Tab Bar"].buttons["Locations"].tap()
        let searchField = app.navigationBars["Locations"].searchFields["Search"]
        searchField.tap()
        searchField.typeText("Berlin, Germany")
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Berlin - DE"]/*[[".cells.buttons[\"Berlin - DE\"]",".buttons[\"Berlin - DE\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
