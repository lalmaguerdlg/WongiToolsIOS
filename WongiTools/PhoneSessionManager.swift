//
//  PhoneSessionManager.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation
import WatchConnectivity

protocol PhoneSessionManagerDelegate {
    func didReceiveHeartRate(_ heartRate: Double) -> Void
}

class PhoneSessionManager: NSObject, ObservableObject {
    static let shared = PhoneSessionManager();
    var session: WCSession
    @Published var isReachable = false
    var delegate: PhoneSessionManagerDelegate?
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
}

extension PhoneSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session started \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received", message)
        if let heartRate = message[WatchConnectivityConstants.heartRate] as? Double {
            self.delegate?.didReceiveHeartRate(heartRate)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    
    
    
    
}
