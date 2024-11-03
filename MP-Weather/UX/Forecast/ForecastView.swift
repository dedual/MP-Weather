//
//  ForecastView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

struct ForecastView: View {
    
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var viewModel: ForecastViewModel
    @State private var orientation = UIDeviceOrientation.unknown
    // MARK: - Views
    var noWeatherView: some View
    {
        return VStack {
            Text("Cannot retrieve weather forecast").font(.largeTitle)
            Spacer()
            if UserPreferences.lastRetrievedLocationInfo == nil
            {
                Button {
                    // go to search view
                    Task{ @MainActor in
                        viewModel.switchTo(tab: .search)
                    }
                    
                } label: {
                    Text("Search for a location in the search view").font(.title)
                }
                .accessibilityLabel(Text("Tap to use search for a specific location to retrieve a weather forecast"))

                Text("or maybe").font(.title)
                Button {
                    // trigger location request
                    Task{@MainActor in 
                        await viewModel.refreshForecastUsingLocation()
                    }
                } label: {
                    Text("Use your device's location?").font(.title)
                }
                .accessibilityLabel(Text("Tap to use your device's location to retrieve a weather forecast"))

            }
            else
            {
                Text("Pull to refresh").font(.title)
                
            }
            Spacer()
        }
        .navigationTitle("Unknown Location")
        .padding([.all], 40)
    }
    
    @ViewBuilder
    var horizontalForecastView: some View {
        if let multidayForecast = viewModel.multidayForecast
        {
            ScrollView(.vertical){
                VStack{
                    Text("Forecast").font(.largeTitle).frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal){
                        HStack(alignment: .center, spacing: 10.0)
                        {
                            ForEach(multidayForecast.forecasts){ aForecast in
                                Button(action: {
                                }, label: {
                                    VStack(alignment:.center) {
                                        Text("\(viewModel.makeDayText(date: aForecast.dateForecasted))").bold()
                                        Text("\(viewModel.makeHourText(date: aForecast.dateForecasted))").bold()
                                        
                                        AsyncImage(url: aForecast.weather.first?.icon2XURL) {
                                            phase in
                                            switch phase {
                                            case .success(let image ):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: horizontalSizeClass == .regular ? 150 : 85, height: horizontalSizeClass == .regular ? 150 : 85)
                                            default:
                                                ProgressView()
                                            }
                                        }
                                        Text(aForecast.weather.first?.description ?? "")
                                    }
                                    .background(Color.black.opacity(0.1))
                                })
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        else {
            Text("No forecasts found! ")
        }
    }
    
    @ViewBuilder
    var forecastView: some View {
        if let forecast = viewModel.currentForecast {
            ScrollView{
                VStack(alignment: .center ,spacing: 10) {
                    ForecastWeatherIconView(currentForecast:forecast)
                    Spacer()
                    VStack(alignment: .center ,spacing: 10) {
                        HStack(alignment: .center, spacing: 10.0) {
                            Spacer()
                            Text("Lows at: " + "\(viewModel.cleanNumberDisplay(forecast.forecast.coreMeasurements.minTemperature))" + " " + "\(UserPreferences.getPreferredMeasurementUnit.unitText)")
                                .font(.headline)
                            Spacer()
                            Text("Highs at: " + "\(viewModel.cleanNumberDisplay(forecast.forecast.coreMeasurements.maxTemperature))" + " " + "\(UserPreferences.getPreferredMeasurementUnit.unitText)").font(.headline)
                            Spacer()
                        }
                    }
                    Spacer()
                    VStack(alignment: .center ,spacing: 10) {
                        HStack(alignment: .center, spacing: 10.0)
                        {
                            Spacer()
                            Text("Pressure at: " + "\(forecast.forecast.coreMeasurements.pressure)" + " " + "hPa")
                                .font(.headline)
                            Spacer()
                            Text("Humidity at: " + "\(forecast.forecast.coreMeasurements.humidity)" + " " + "%").font(.headline)
                            Spacer()
                        }
                    }
                    Spacer()
                    if let multidayForecast = viewModel.multidayForecast
                    {
                        Text("Forecast").font(.largeTitle).frame(maxWidth: .infinity, alignment: .leading)
                        ScrollView(.horizontal)
                        {
                            HStack(alignment: .center, spacing: 10.0)
                            {
                                ForEach(multidayForecast.forecasts){ aForecast in
                                    Button(action: {
                                    }, label: {
                                        VStack(alignment:.center) {
                                            Text("\(viewModel.makeDayText(date: aForecast.dateForecasted))").bold()
                                            Text("\(viewModel.makeHourText(date: aForecast.dateForecasted))").bold()
                                            
                                            AsyncImage(url: aForecast.weather.first?.icon2XURL) {
                                                phase in
                                                    switch phase {
                                                    case .success(let image ):
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 75, height: 75)
                                                    default:
                                                        ProgressView()
                                                    }
                                            }
                                            Text(aForecast.weather.first?.description ?? "")
                                        }
                                        .background(Color.black.opacity(0.1))
                                    })
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .accessibilityHint("Scroll left and right to get more forecast information")
                    }
                }
                .padding()
            }
            .navigationTitle(forecast.locationInfo.name)
        }
    }
    
    var body: some View {
        NavigationStack {
            if let forecast = viewModel.currentForecast {
                
                if orientation.isPortrait || orientation.isFlat || orientation == .unknown{
                    self.forecastView
                        .background {
                            Color(UIColor.systemGroupedBackground)
                        }
                } else if orientation.isLandscape {
                    self.horizontalForecastView
                        .background {
                            Color(UIColor.systemGroupedBackground)
                    }
                }
            }
            else {
                self.noWeatherView
                    .background {
                        Color(UIColor.systemGroupedBackground)
                    }
            }
        }
        .background {
            Color(UIColor.systemGroupedBackground)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Uh-oh"), message: Text(viewModel.showAlertMessage ?? "An error has occured!"), dismissButton: .default(Text("Okay")))
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .navigationBarModifier(backgroundColor: UIColor.systemGroupedBackground, tintColor: nil, withSeparator: true)
        .tabBarModifier(backgroundColor: UIColor.systemGroupedBackground, tintColor: nil, withSeparator: true)
        .onRotate { newOrientation in
            orientation = newOrientation
        }
        .onAppear {
            if UserPreferences.alwaysUseUserLocation || UserPreferences.tempUseUserLocation {
                Task { @MainActor in
                    await viewModel.refreshForecastUsingLocation()
                    UserPreferences.tempUseUserLocation = false
                }
            } else if let location = UserPreferences.lastRetrievedLocationInfo {
                Task {@MainActor in 
                    await viewModel.refreshForecast(locationInfo: location)
                }
            }
        }
        .refreshable {
            Task{@MainActor in
                if !viewModel.isLoading {
                    if UserPreferences.alwaysUseUserLocation {
                        await viewModel.refreshForecastUsingLocation()
                    } else if let location = UserPreferences.lastRetrievedLocationInfo {
                        await viewModel.refreshForecast(locationInfo: location)
                    }
                }
            }
        }
    }
}
