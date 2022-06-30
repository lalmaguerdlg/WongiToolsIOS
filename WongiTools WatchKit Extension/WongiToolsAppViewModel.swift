//
//  WongiAppViewModel.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation

final class WongiToolsAppViewModel: ObservableObject {
    struct Dependencies {
        var workoutManager: WorkoutManager = WorkoutManager.shared
        var watchSessionManager: WatchSessionManager = WatchSessionManager.shared
        var sendHeartRate: SendHeartRate = SendHeartRateAdapter()
        var stopWorkoutSession = StopWorkoutSessionAdapter()
    }
    
    private let dependencies: Dependencies
    
    var workoutManager: WorkoutManager {
        get {
            return dependencies.workoutManager
        }
    }
    
    var watchSessionManager: WatchSessionManager {
        get {
            return dependencies.watchSessionManager
        }
    }
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
        self.dependencies.workoutManager.delegate = self
        self.dependencies.watchSessionManager.delegate = self
    }
}

extension WongiToolsAppViewModel: WorkoutManagerDelegate {
    func didReceiveHKHeartRate(_ heartRate: Double) {
        self.dependencies.sendHeartRate.execute(heartRate)
    }
}

extension WongiToolsAppViewModel: WatchSessionManagerDelegate {
    func didReceiveStopSessionSignal(_ shouldStop: Bool) {
        self.dependencies.stopWorkoutSession.execute(shouldStop);
    }
}
