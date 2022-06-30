//
//  WTServerService.swift
//  WongiTools
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation

protocol WTServerServiceDelegate {
    func didReachMaxAttepts(attempts: Int, maxAttempts: Int)
}

protocol WTServerServiceProtocol {
    func sendHeartRate(heartRate: Double) -> Void
    func isAlive() -> Bool
    func getProve() -> WTServerProve
}

class WTServerService: ObservableObject {
    static var shared = WTServerService(maxAttempts: 10)
    var delegate: WTServerServiceDelegate?
    
    var maxAttempts: Int = 10
    @Published var address = WTAddress()
    @Published var status: WTServerStatus = .unknown
    @Published var attempts: Int = 0
    @Published var lastSentAt: Date?
    
    var timer: Timer?
    
    init(maxAttempts: Int) {
        self.maxAttempts = maxAttempts
        self.loadAddress()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func getProve() -> WTServerProve {
        return WTServerProve(address: self.address)
    }
    
    func isAlive() -> Bool {
        return status == .alive
    }
    
    private func startTimer() {
        if let timer = timer {
            guard !timer.isValid else { return }
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.1, repeats: true, block: {
            [weak self] _ in
            guard let self = self else { return }
            guard let lastSentAt = self.lastSentAt else {
                return
            }
            let now = Date()
            if now.timeIntervalSince(lastSentAt) > 5 && self.isAlive() {
                self.status = .idle
            }
        })
    }
    
    struct HeartData: Codable {
        var bpm: Double = 0.0
    }
    
    func postHeartRate(_ heartRate: Double) {
        if self.status != .alive {
            DispatchQueue.main.async {
                self.status = .proving
            }
        }
        guard address.isValid() else {
            DispatchQueue.main.async {
                self.status = .dead
            }
            return
        }
        Task {
            guard let url = URL(string: "http://\(address.description)/heart") else {
                print("Invalid URL")
                DispatchQueue.main.async {
                    self.status = .dead
                }
                return
            }
            var request = URLRequest(url: url);
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            let data = HeartData(bpm: heartRate)
            
            guard let encoded = try? JSONEncoder().encode(data) else {
                print("Error while encoding heartRate")
                return
            }
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 3.0
            config.timeoutIntervalForResource = 3.0
            let session = URLSession(configuration: config)
            do {
                let _ = try await session.upload(for: request, from: encoded)
                DispatchQueue.main.async {
                    self.status = .alive
                    self.attempts = 0
                    self.startTimer()
                }
                print("HeartRate uploaded")
            } catch {
                DispatchQueue.main.async {
                    self.status = .dead
                    self.attempts += 1
                    self.timer?.invalidate()
                    if self.attempts >= self.maxAttempts {
                        self.delegate?.didReachMaxAttepts(attempts: self.attempts, maxAttempts: self.maxAttempts)
                    }
                }
                
                print("Error while sending heart rate \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.lastSentAt = Date()
            }
        }
    }
    
    private func loadAddress() {
        let defaults = UserDefaults.standard
        if let ip = defaults.string(forKey: UserDefaultConstants.WTServerIP) {
            address.ip = ip
        }
        let port = defaults.integer(forKey: UserDefaultConstants.WTServerPort)
        if port > 0 {
            self.address.port = UInt16(port)
        }
    }
    
}



