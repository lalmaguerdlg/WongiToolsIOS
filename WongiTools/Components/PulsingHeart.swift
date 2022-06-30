//
//  PulsingHeart.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import SwiftUI

struct PulsingHeart: View {
    @State var animationAmount = 1.0
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: 15, height: 15)
            .foregroundColor(.red)
            .scaleEffect(animationAmount)
            .animation(
                .linear(duration: 0.4)
                .delay(0.2)
                .repeatForever(autoreverses: true)
                .speed(1.0),
                value: animationAmount)
            .onAppear() {
                animationAmount = 1.2
            }
    }
}

struct PulsingHeart_Previews: PreviewProvider {
    static var previews: some View {
        PulsingHeart()
    }
}
