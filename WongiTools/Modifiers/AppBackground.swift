//
//  AppBackground.swift
//  WongiTools
//
//  Created by Luis Almaguer on 26/06/22.
//

import Foundation
import SwiftUI

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.134, green: 0.108, blue: 0.163).ignoresSafeArea(.all))
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }
}
