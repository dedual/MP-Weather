//
//  ForecastWeatherIconView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

struct ForecastWeatherIconView: View {
    
    let currentForecast:CurrentForecast
    private func cleanNumberDisplay(_ input:Double) -> String {
        let formatter = NumberFormatter()

        formatter.usesSignificantDigits = true
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 2
        
        if let result = formatter.string(from: input as NSNumber) {
            return result
        }
        else {
            return "\(input)"
        }
    }
    
    private func makeHourText(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale(identifier: UserPreferences.getPreferredLanguage)
        return dateFormatter.string(from: date)
    }

    var body: some View {
        HStack(alignment:.center, spacing:10.0){
            Spacer()
            VStack(alignment: .center) {
                AsyncImage(url: currentForecast.forecast.weather.first?.icon2XURL) { phase in
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
                Text(currentForecast.forecast.weather.first?.description ?? "")
                    .padding()
            }
            .background(Color.black.opacity(0.1))
            
            Spacer()
            VStack(alignment:.leading, spacing: 5) {
                Text("\(cleanNumberDisplay(currentForecast.forecast.coreMeasurements.temperature))" + " " + "\(UserPreferences.getPreferredMeasurementUnit.unitText)").fontWeight(.bold)
                Text("feels like " + "\(cleanNumberDisplay(currentForecast.forecast.coreMeasurements.temperature))" + " " + "\(UserPreferences.getPreferredMeasurementUnit.unitText)")
                Text("Visibility: \(cleanNumberDisplay(100.0 * currentForecast.forecast.visibilityPercentage))%")
                Text("Sunrise at: \(makeHourText(date: currentForecast.locationInfo.sunriseDate))")
                // TODO: - known issue: sunrise and sunset is calculated relative to device's local timezone. Must fix
                Text("Sunset at: \(makeHourText(date: currentForecast.locationInfo.sunsetDate))")
            }
            Spacer()
        }
    }
}
