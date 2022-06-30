//
//  StopWorkoutSession.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation

protocol StopWorkoutSession {
    func execute(_ shouldStop: Bool)
}

final class StopWorkoutSessionAdapter: StopWorkoutSession {
    struct Dependencies {
        let workoutManager = WorkoutManager.shared
    }
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
    }
    
    func execute(_ shouldStop: Bool) {
        if (shouldStop) {
            DispatchQueue.main.async {
                self.dependencies.workoutManager.stopWorkout()
            }
        }
        
    }
}
