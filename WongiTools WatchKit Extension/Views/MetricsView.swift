//
//  MetricsView.swift
//  WongiTools WatchKit Extension
//
//  Created by Luis Almaguer on 25/06/22.
//

import SwiftUI
import WatchConnectivity

struct MetricsView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(from: workoutManager.workoutBuilder?.startDate ?? Date())
        ) { context in
            
            ZStack(alignment: .leading) {
                VStack {
                    Image("logo-pu-dark-figma")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-35))
                        .offset(x: 20, y: 20)
                        .ignoresSafeArea()
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                
                VStack {
                    WatchConnectivityStatus()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding([.top, .leading])
                
                VStack {
                    HStack {
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
                        
                        Text(
                            workoutManager.heartRate.formatted(
                                .number.precision(.fractionLength(0))
                            )
                            + " bpm"
                        )
                    }
                    .font(.system(.title, design: .rounded)
                        .monospacedDigit()
                        .lowercaseSmallCaps()
                    )
                    ElapsedTimeView(
                        elapsedTime: workoutManager.workoutBuilder?.elapsedTime ?? 0,
                        showSubseconds: context.cadence == .live
                    )
                    .font(.system(.subheadline, design: .rounded)
                        .monospacedDigit()
                        .lowercaseSmallCaps()
                    )
                    .foregroundColor(Color.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
        }
        
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView()
            .environmentObject(WorkoutManager.shared)
            .environmentObject(WatchSessionManager.shared)
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date
    
    init(from startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
        ).entries(
            from: startDate,
            mode: mode
        )
    }
}
