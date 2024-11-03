//
//  SearchCoordinatorView.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import SwiftUI

struct SearchCoordinatorView: View {
    
    @State var coordinator: SearchCoordinator
    
    var body: some View {
        SearchView(viewModel: coordinator.viewModel)
    }
}
