//
//  ForecastCoordinatorView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

struct ForecastCoordinatorView: View {
    
    @State var coordinator: ForecastCoordinator
    
    var body: some View {
        ForecastView(viewModel: coordinator.viewModel)
            .background {
                Color(UIColor.systemGroupedBackground)
            }
    }
}
