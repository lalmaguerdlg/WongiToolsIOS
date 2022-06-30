//
//  TestConnectionButton.swift
//  WongiTools
//
//  Created by Luis Almaguer on 27/06/22.
//

import SwiftUI

struct TestConnectionButton: View {
    @ObservedObject var prove: WTServerProve
    
    var proveOnAppear: Bool = false
    
    var body: some View {
        Button {
            prove.execute()
        } label: {
            HStack {
                Text("Test connection")
                Spacer()
                WTServerStatusCircle(status: prove.status)
            }
        }
        .disabled(prove.status == .proving)
        .onAppear {
            if proveOnAppear && prove.status != .proving {
                prove.execute()
            }
        }
    }
}

struct TestConnectionButton_Previews: PreviewProvider {
    static var previews: some View {
        TestConnectionButton(prove: WTServerService.shared.getProve())
    }
}
