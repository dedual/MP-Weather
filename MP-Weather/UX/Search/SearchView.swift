//
//  SearchView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @SwiftUI.Environment(\.isSearching) var isSearching
    @SwiftUI.Environment(\.dismissSearch) var dismissSearch
    
    @State var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.filteredRetrievedLocations.count == 0 {
                    Button {
                        // trigger location request
                        dismissSearch()
                        UserPreferences.tempUseUserLocation = true
                        viewModel.searchLocationsText = ""
                        viewModel.switchTo(tab: .forecast)
                    } label: {
                        Text("Get your local weather report")
                    }
                    
                    if viewModel.previousLocations.count > 0 {
                        Section(header: Text("Previous Locations").font(.subheadline)) {
                            ForEach(Array(viewModel.previousLocations)) { location in
                                VStack(alignment: .leading) {
                                    Button(action: {
                                        // trigger API call
                                        dismissSearch()
                                        UserPreferences.lastRetrievedLocationInfo = location
                                        viewModel.searchLocationsText = ""
                                        viewModel.switchTo(tab: .forecast)
                                    }){
                                        Text(location.name)
                                            .font(.headline)
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    ForEach(viewModel.filteredRetrievedLocations) { location in
                        VStack(alignment: .leading) {
                            Button(action: {
                                // trigger API call
                                dismissSearch()
                                UserPreferences.lastRetrievedLocationInfo = location
                                viewModel.previousLocations.insert(location)
                                viewModel.searchLocationsText = ""
                                viewModel.switchTo(tab: .forecast)

                                
                            }){
                                Text(location.name)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Locations")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Uh-oh"), message: Text(viewModel.showAlertMessage ?? "An error has occured!"), dismissButton: .default(Text("Okay")))
        }
        .searchable(text: $viewModel.searchLocationsText)
        .onChange(of: viewModel.searchLocationsText){ _, newValue in
            Task{
                await viewModel.runSearch(searchLocation: newValue)
            }
        }
        .onSubmit(of: .search) {
            Task {
                await viewModel.runSearch(searchLocation: viewModel.searchLocationsText)
                guard let location = viewModel.retrievedLocations.first else {
                    viewModel.showAlertMessage = "No locations found. Try another queryn"
                    viewModel.showAlert = true
                    return
                }
                dismissSearch()
                UserPreferences.lastRetrievedLocationInfo = location
                viewModel.previousLocations.insert(location)
                viewModel.searchLocationsText = ""
                viewModel.switchTo(tab: .forecast)
            }
        }
    }

}
