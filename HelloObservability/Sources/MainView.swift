//
//  MainView.swift
//  HelloObservability
//
//  Created by Ilya Lobanov on 29.07.2023.
//

import SwiftUI


enum NavigationDestination: String, Equatable, Identifiable {
    case timer = "Timer"
    
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
            List([NavigationDestination.timer]) { destination in
                NavigationLink(destination.rawValue, value: destination)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .timer:
                    TimerView()
                }
            }
        }
    }
    
}

#Preview {
    MainView()
}
