//
//  ContentView.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 17/06/22.
//

import SwiftUI

struct StartView: View {
    @State private var selection: Tab = .controls
    enum Tab {
        case controls, metrics
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Controls().tag(Tab.controls)
            Text("Metrics").tag(Tab.metrics)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
