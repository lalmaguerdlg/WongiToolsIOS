//
//  PulseCircle.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import SwiftUI

struct PulseCircle: View {
    var animationEnabled: Bool
    @State var animationState = false
    var color: Color = .white
    var width: Double = 10.0
    var height: Double = 10.0
    
    init(fill: Color, animate: Bool = false) {
        self.color = fill
        self.animationEnabled = animate
    }
    
    init(fill: Color = .gray, width: Double = 10.0, height: Double = 10.0, animate: Bool = false) {
        self.color = fill
        self.width = width
        self.height = height
        self.animationEnabled = animate
    }
    
    var shouldAnimate: Bool {
        self.animationEnabled && self.animationState
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: width, height: height)
                .opacity(shouldAnimate ? 0.3 : 0)
                .scaleEffect(shouldAnimate ? 1.5 : 0.9)
                .animation(shouldAnimate ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: shouldAnimate)
                
            Circle()
                .fill(color)
                .frame(width: width, height: width)
        }
        .onAppear {
            animationState = true
        }
        .onDisappear {
            animationState = false
        }
    }
}

struct PulseCircle_Previews: PreviewProvider {
    static var previews: some View {
        PulseCircle(fill: .gray, width: 10.0, height: 10.0, animate: true)
    }
}
