//
//  PhoneModelView.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation

final class PhoneViewModel: ObservableObject {
    struct Dependencies {
        var workoutManager: WorkoutManager = WorkoutManager.shared
        var watchSessionManager: WatchSessionManager = WatchSessionManager.shared
        var sendHeartRate: SendHeartRate = SendHeartRateAdapter()
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
    }
}

extension WongiToolsAppViewModel: WorkoutManagerDelegate {
    func didReceiveHKHeartRate(_ heartRate: Double) {
        self.dependencies.sendHeartRate.execute(heartRate)
    }
}
