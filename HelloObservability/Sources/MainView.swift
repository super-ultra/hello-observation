//
//  MainView.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 29.07.2023.
//

import SwiftUI


enum NavigationDestination: String, Equatable, Identifiable, CaseIterable {
    case observationTimer = "Observation Timer"
    case combineTimer = "Combine Timer"
    
    var id: String {
        rawValue
    }
}


@MainActor
struct MainView: View {
    
    @State
    private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(NavigationDestination.allCases) { destination in
                NavigationLink(destination.rawValue, value: destination)
            }
            .navigationTitle("Hello")
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .observationTimer:
                    ObservationTimerView()
                case .combineTimer:
                    CombineTimerView(viewModel: CombineTimerViewModelImpl.system())
                }
            }
        }
    }
    
}


#Preview {
    MainView()
}
