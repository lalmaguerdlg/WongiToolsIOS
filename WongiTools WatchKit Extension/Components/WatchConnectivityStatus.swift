//
//  WatchConnectivityStatus.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 26/06/22.
//

import SwiftUI
import WatchConnectivity

struct WatchConnectivityStatus: View {
    @EnvironmentObject private var watchSessionManager: WatchSessionManager
    @State private var animatingPulse = false
    
    var animateStatus: Bool {
        return watchSessionManager.isReachable && WCSession.default.isCompanionAppInstalled && animatingPulse
    }
    var body: some View {
        ZStack {
            Circle()
                .fill(animateStatus ? .green : .red)
                .frame(width: 15, height: 15)
                .opacity(animateStatus ? 0.3 : 0)
                .scaleEffect(animateStatus ? 1.5 : 0.9)
                .animation(animateStatus ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: animateStatus)
                
            Circle()
                .fill(animateStatus ? .green : .red)
                .frame(width: 15, height: 15)
        }
        .onAppear {
            animatingPulse = true
        }
        .onDisappear {
            animatingPulse = false
        }
    }
}

struct WatchConnectivityStatus_Previews: PreviewProvider {
    static var previews: some View {
        WatchConnectivityStatus()
            .environmentObject(WatchSessionManager.shared)
    }
}
