//
//  ContentView.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 17/06/22.
//

import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = WongiToolsAppViewModel()
    @State private var selection: Tab = .controls
    enum Tab {
        case controls, metrics
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView(tabSelection: $selection).tag(Tab.controls)
            MetricsView().tag(Tab.metrics)
        }
        .animation(.easeOut(duration: 0.2), value: selection)
        .environmentObject(viewModel.workoutManager)
        .environmentObject(viewModel.watchSessionManager)
        .onAppear {
            WorkoutManager.authorizeHealthKit()
            if viewModel.workoutManager.running {
                selection = .metrics
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
