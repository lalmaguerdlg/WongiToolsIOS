//
//  WTServerFinder.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation
import Network
import CocoaAsyncSocket

protocol WTServerFinderDelegate {
    func statusDidChange(_ status: WTServerFinder.Status, error: Error?) -> Void
    func serviceDidFound(_ foundAddress: WTAddress) -> Void
}

class WTServerFinder: NSObject, ObservableObject {
    var delegate: WTServerFinderDelegate?
    
    private let IP = "255.255.255.255"
    private let PORT:UInt16 = 17177
    private let BIND_PORT:UInt16 = 34567
    private var socket:  GCDAsyncUdpSocket?
    private let BROADCAST_MESSAGE = "wongi-tools.service"
    private var attempts: Int = 0
    private let MAX_ATTEMPTS = 5
    
    var timer: Timer?
    
    enum Status {
        case idle, searching, timedout, error, stopped, success
    }
    
    @Published var status: Status = .idle
    
    override init() {
        super.init()
    }
    
    func setupConnection() {
        if self.socket != nil && !self.socket!.isClosed() {
            self.socket!.close()
        }
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        guard let socket = self.socket else {
            return
        }

        do {
            try socket.bind(toPort: BIND_PORT)
            try socket.enableBroadcast(true)
            try socket.beginReceiving()
        }
        catch {
            print("error while trying to connect", error)
        }
    }
    
    private func closeConnection() {
        guard let socket = socket else { return }
        socket.pauseReceiving()
        socket.close()
    }

    private func updateStatus(_ status: Status, error: Error? = nil) {
        if self.status != status || status == .error {
            self.status = status
            self.delegate?.statusDidChange(self.status, error: nil)
        }
        
        if self.status != .searching {
            closeConnection()
        }
    }
    
    func beginSearch() {
        guard status != .searching else { return }
        self.attempts = 0
        if let timer = timer {
            guard !timer.isValid else {
                print("You must stop the search first!")
                return
            }
        }
        
        setupConnection()
        
        updateStatus(.searching)
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: {
            [weak self] _ in
            guard let self = self else { return }
            guard self.attempts < self.MAX_ATTEMPTS else {
                DispatchQueue.main.async {
                    self.stopSearch(reason: .timedout)
                }
                return
            }
            if self.status != .searching {
                DispatchQueue.main.async {
                    self.updateStatus(.searching)
                }
            }
            self.attempts += 1
            print("Attempt \(self.attempts): sending broadcast message")
            self.send(message: "wongi-tools.service")
        })
    }
    
    func stopSearch() {
        stopSearch(reason: .stopped)
    }
    
    private func stopSearch(reason: Status, error: Error? = nil) {
        print("stopping")
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        
        DispatchQueue.main.async {
            self.updateStatus(reason, error: error)
        }
    }
    
    func send(message:String){
        let data = message.data(using: String.Encoding.utf8)
        if let data = data {
            socket?.send(data, toHost: IP, port: PORT, withTimeout: 2, tag: 0)
        }
    }
}

extension WTServerFinder: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard !data.isEmpty else { return }
        let msg = String(decoding: data, as: UTF8.self)
        print("incoming message: \(msg)");
        
        let address = try? JSONDecoder().decode(WTAddress.self, from: data)
        guard let address = address else {
            print("Incoming message is not a valid WTAddress \(msg)")
            return
        }
        
        DispatchQueue.main.async {
            self.stopSearch(reason: .success)
            self.delegate?.serviceDidFound(address)
        }
        
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("socket did not connect")
        if let error = error {
            print(error)
            DispatchQueue.main.async {
                self.stopSearch(reason: .error, error: error)
            }
        }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("socket did close")
        if let error = error {
            print(error)
            DispatchQueue.main.async {
                self.stopSearch(reason: .error, error: error)
            }
        }
    }
}
