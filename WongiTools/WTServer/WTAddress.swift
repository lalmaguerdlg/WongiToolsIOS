//
//  WTAddress.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import Foundation

struct WTAddress: Codable {
    var ip: String = ""
    var port: UInt16 = 0
}

extension WTAddress: CustomStringConvertible {
    var description: String {
        return "\(ip):\(port)"
    }
}

extension WTAddress {
    static func validateIp(_ ip: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
        let range = NSRange(location: 0, length: ip.utf16.count)
        return regex.firstMatch(in: ip, range: range) != nil
    }
    
    func isValid() -> Bool {
        return !ip.isEmpty && port > 0 && WTAddress.validateIp(ip)
    }
}
