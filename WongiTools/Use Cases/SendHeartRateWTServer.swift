//
//  SendHeartRateWTServer.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation
import WatchConnectivity

protocol SendHeartRateWTServer {
    func execute(_ heartRate: Double)
}

final class SendHeartRateWTServerAdapter: SendHeartRateWTServer {
    struct Dependencies {
        let wtServerService = WTServerService.shared
    }
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
    }
    
    func execute(_ heartRate: Double) {
        let wtServer = self.dependencies.wtServerService;
        wtServer.postHeartRate(heartRate)
    }
}
