//
//  SendWatchStopSignal.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation
import WatchConnectivity

protocol SendWatchStopSignal {
    func execute(_ shouldStop: Bool)
}

final class SendWatchStopSignalAdapter: SendWatchStopSignal {
    struct Dependencies {}
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = .init()) {
        self.dependencies = dependencies
    }
    
    func execute(_ shouldStop: Bool) {
        guard WCSession.isSupported() else { return }
        guard WCSession.default.isReachable else {
            print("Session not reachable")
            return
        }
        guard WCSession.default.isWatchAppInstalled else {
            print("Companion app not installed")
            return
        }
        print("We failed to sent heart rate data more than 10 times. Stopping workout")
        WCSession.default.sendMessage([WatchConnectivityConstants.stopSession:shouldStop], replyHandler: nil)
    }
}
