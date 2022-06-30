//
//  PhoneModelView.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation

final class PhoneViewModel: ObservableObject {
    @Published var heartRate: Double = 0.0
    
    struct Dependencies {
        var wtServerService = WTServerService.shared
        var phoneSessionManager: PhoneSessionManager = PhoneSessionManager.shared
        var sendHeartRate: SendHeartRateWTServerAdapter = SendHeartRateWTServerAdapter()
        var sendWatchStopSignal: SendWatchStopSignal = SendWatchStopSignalAdapter()
    }
    
    private let dependencies: Dependencies
    
    var wtServerService: WTServerService {
        get {
            return dependencies.wtServerService
        }
    }
    var phoneSessionManager: PhoneSessionManager {
        get {
            return dependencies.phoneSessionManager
        }
    }
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
        self.dependencies.phoneSessionManager.delegate = self
        self.dependencies.wtServerService.delegate = self
    }
}

extension PhoneViewModel: PhoneSessionManagerDelegate {
    func didReceiveHeartRate(_ heartRate: Double) {
        DispatchQueue.main.async {
            self.heartRate = heartRate
        }
        self.dependencies.sendHeartRate.execute(heartRate)
    }
}

extension PhoneViewModel: WTServerServiceDelegate {
    func didReachMaxAttepts(attempts: Int, maxAttempts: Int) {
        self.dependencies.sendWatchStopSignal.execute(true);
    }
}
