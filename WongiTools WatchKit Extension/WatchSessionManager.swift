//
//  WatchSessionManager.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation
import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func didReceiveStopSessionSignal(_ shouldStop: Bool)
}

class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager();
    var session: WCSession
    @Published var isReachable = false
    var delegate: WatchSessionManagerDelegate?
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
}

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session started \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("received application context")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received", message)
        if let stop = message[WatchConnectivityConstants.stopSession] as? Bool {
            self.delegate?.didReceiveStopSessionSignal(stop)
        }
    }
}
