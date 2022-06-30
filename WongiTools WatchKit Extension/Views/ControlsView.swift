//
//  ControlsView.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 17/06/22.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    @Binding var tabSelection: StartView.Tab
    @State var running: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Image("logo-pu-dark-figma")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(35))
                    .offset(x: -20, y: 20)
                    .ignoresSafeArea()
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .bottomLeading)
            
            VStack {
                WatchConnectivityStatus()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding([.top, .leading])
            
            
            VStack {
                Button {
                    if workoutManager.running {
                        workoutManager.stopWorkout()
                        running = false
                    } else {
                        workoutManager.startWorkout()
                        running = true
                        tabSelection = .metrics
                    }
                } label: {
                    Image(systemName: workoutManager.running ? "xmark" : "play.fill")
                }
                .disabled(self.running != workoutManager.running)
                .tint(workoutManager.running ? Color.red : Color.green)
                .font(.title2)
                .foregroundColor(workoutManager.running ? .red : .green)
                .onAppear {
                    self.running = workoutManager.running
                }
                Text(workoutManager.running ? "Stop" : "Start")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea(edges: .bottom)
        .scenePadding()
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(tabSelection: Binding.constant(.controls))
            .environmentObject(WorkoutManager.shared)
            .environmentObject(WatchSessionManager.shared)
    }
}
