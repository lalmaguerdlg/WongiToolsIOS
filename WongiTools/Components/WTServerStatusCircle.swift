//
//  WTServerStatusCircle.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import SwiftUI

struct WTServerStatusCircle: View {
    var status: WTServerStatus = .unknown
    var body: some View {
        if status == .proving {
            PulseCircle(fill: .blue, animate: true)
        } else if status == .alive {
            PulseCircle(fill: .green, animate: true)
        } else if status == .idle {
            PulseCircle(fill: .yellow, animate: true)
        } else if status == .dead {
            PulseCircle(fill: .red)
        } else {
            PulseCircle(fill: .gray)
        }
    }
}

struct WTServerStatusCircle_Previews: PreviewProvider {
    static var previews: some View {
        WTServerStatusCircle()
    }
}
