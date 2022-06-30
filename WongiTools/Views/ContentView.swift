//
//  ContentView.swift
//  WongiTools
//
//  Created by Luis Almaguer on 17/06/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var phoneViewModel = PhoneViewModel()
    @ObservedObject var wtServerService = WTServerService.shared;
    
    var wtServer: WTServerService {
        phoneViewModel.wtServerService
    }
    @State var showingConfigSheet = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    PhoneSessionStatusCircle()
                    WTServerStatusCircle(status: wtServer.status)
                    if wtServer.attempts > 0 {
                        Text(wtServer.attempts.description)
                            .font(.system(.headline, design: .rounded)
                                .monospacedDigit())
                            .foregroundColor(.red)
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        showingConfigSheet.toggle()
                    } label: {
                        if wtServer.address.isValid() {
                            Text(wtServer.address.description)
                        } else {
                            Text("Configure Remote Address")
                        }
                    }
                    .font(.system(.headline, design: .rounded)
                        .monospacedDigit())
                    .sheet(isPresented: $showingConfigSheet) {
                        ConfigView()
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            VStack {
                HStack {
                    PulsingHeart()
                    Text(
                        phoneViewModel.heartRate.formatted(
                            .number.precision(.fractionLength(0))
                        )
                        + " bpm"
                    )
                }
                .font(.system(.title, design: .rounded)
                    .monospacedDigit()
                    .lowercaseSmallCaps()
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .foregroundColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
