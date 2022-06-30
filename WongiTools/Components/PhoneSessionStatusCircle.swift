//
//  PhoneSessionStatusCircle.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import SwiftUI

struct PhoneSessionStatusCircle: View {
    @ObservedObject var phoneSessionManager = PhoneSessionManager.shared
    var isOk: Bool {
        phoneSessionManager.isReachable
    }
    var body: some View {
        PulseCircle(fill: isOk ? .green : .red, animate: isOk)
    }
}

struct PhoneSessionStatusCircle_Previews: PreviewProvider {
    static var previews: some View {
        PhoneSessionStatusCircle()
    }
}
