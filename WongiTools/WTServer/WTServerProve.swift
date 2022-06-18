//
//  WTServerProve.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation

protocol WTServerProveProtocol {
    func execute() -> Void
    func isAlive() -> Bool
}

final class Box<T>: NSObject {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}

final class WTServerProveCache {
    static let shared = WTServerProveCache()
    private var cache = NSCache<NSString, Box<WTServerStatus>>()
    
    func set(value: WTServerStatus, forKey: String) {
        cache.setObject(Box(value), forKey: forKey as NSString)
    }
    
    func get(forKey: String) -> WTServerStatus? {
        return cache.object(forKey: forKey as NSString)?.value
    }
}

class WTServerProve: ObservableObject {
    private var _address: WTAddress
    var address: WTAddress {
        get { return _address }
        set {
            self.address = newValue
            if let cachedStatus = WTServerProveCache.shared.get(forKey: address.description) {
                self.status = cachedStatus
                self._isStale = true;
            } else {
                self.status = .unknown
            }
        }
    }
    private var _isStale: Bool = false
    var isStale: Bool {
        get { return _isStale }
    }
    @Published var status: WTServerStatus = .unknown
    
    init(address: WTAddress) {
        self._address = address
        if let cachedStatus = WTServerProveCache.shared.get(forKey: address.description) {
            self.status = cachedStatus
            self._isStale = true
        }
    }
    
    func isAlive() -> Bool {
        return status == .alive
    }
    
    func execute() {
        print(status)
        print("Proving...", address.description)
        status = .proving
        guard address.isValid() else {
            status = .dead
            print("Invalid address")
            return
        }
        guard let url = URL(string: "http://\(address.description)/ping") else {
            print("Invalid URL")
            status = .dead
            return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 10.0
        let session = URLSession(configuration: config)
        let currentAddress = self.address
        let task = session.dataTask(with: url) {(data, response, error) in
            var result: WTServerStatus
            if let error = error {
                result = .dead
                print("Server is unaccesible", error)
            } else {
                result = .alive
            }
            if (currentAddress.description == self.address.description) {
                DispatchQueue.main.async {
                    self.status = result
                }
            }
            WTServerProveCache.shared.set(value: result, forKey: currentAddress.description)
        }
        print("Running task")
        task.resume()
        print(status)
    }
}
