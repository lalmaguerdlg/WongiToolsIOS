//
//  SendHeartRate.swift
//  WongiTools
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation
import WatchConnectivity

protocol SendHeartRate {
    func execute(_ heartRate: Double)
}

final class SendHeartRateAdapter: SendHeartRate {
    struct Dependencies {
        let workoutManager = WorkoutManager.shared
    }
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
    }
    
    func execute(_ heartRate: Double) {
        guard WCSession.isSupported() else { return }
        guard WCSession.default.isReachable else {
            print("Session not reachable")
            return
        }
        guard WCSession.default.isCompanionAppInstalled else {
            print("Companion app not installed")
            return
        }
        print("Sending heart rate \(heartRate.description)")
        WCSession.default.sendMessage([WatchConnectivityConstants.heartRate:heartRate], replyHandler: nil)
    }
}
