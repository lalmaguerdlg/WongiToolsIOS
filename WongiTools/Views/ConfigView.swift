//
//  ConfigView.swift
//  WongiTools
//
//  Created by Luis Almaguer on 26/06/22.
//

import SwiftUI
import Combine

class ConfigServerSearch: WTServerFinderDelegate, ObservableObject {
    @Published var status: WTServerFinder.Status = .idle
    @Published var foundAddress: WTAddress?
    private var action: ((_ address: WTAddress) -> Void)?
    
    func onSuccess(action: @escaping ((_ address: WTAddress) -> Void)) {
        self.action = action
    }
    
    func serviceDidFound(_ foundAddress: WTAddress) {
        DispatchQueue.main.async {
            self.foundAddress = foundAddress
            self.action?(foundAddress)
        }
    }
    
    func statusDidChange(_ status: WTServerFinder.Status, error: Error?) {
        print("status did change", status)
        guard error == nil else {
            print(error!)
            return
        }
        DispatchQueue.main.async {
            self.status = status
        }
    }
}

class NumbersOnly: ObservableObject {
    private var allowDot = false
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber || (self.allowDot && $0 == ".") }
            if value != filtered {
                value = filtered
            }
        }
    }
    
    init(initial: String = "", dot: Bool = false) {
        self.allowDot = dot
        self.value = initial
    }
}

struct ConfigView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var wtServerService = WTServerService.shared
    @ObservedObject var ipInput = NumbersOnly(initial: WTServerService.shared.address.ip, dot: true)
    @ObservedObject var portInput: NumbersOnly = {
        let initial = WTServerService.shared.address.port > 0 ? WTServerService.shared.address.port.description : ""
        return NumbersOnly(initial: initial)
    }()
    @State private var ipError: String = ""
    @State private var portError: String = ""
    
    @StateObject private var prove = WTServerService.shared.getProve()
    var serverFinder = WTServerFinder()
    @StateObject var searchState = ConfigServerSearch()
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.system(.largeTitle))
                .bold()
            Form {
                Section(header: Text("WongiTools' Remote Server").foregroundColor(.white)) {
                    
                    VStack(alignment: .leading) {
                        let ipBindig = Binding<String>(get: { self.ipInput.value }, set: {
                            self.ipInput.value = $0
                            self.ipError = ""
                            guard let port = UInt16(portInput.value) else { return }
                            self.prove.address = WTAddress(ip: ipInput.value, port: port)
                        })
                        TextField(text: ipBindig, prompt: Text("IP Address")) {
                            Text("IP Address")
                        }
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .onSubmit {
                            ipError = ""
                            let valid = WTAddress.validateIp(ipInput.value)
                            if !valid {
                                ipError = "Invalid ip address"
                            }
                        }
                        if !ipError.isEmpty {
                            Text(ipError)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    
                    let portBinding = Binding<String>(get: { self.portInput.value }, set: {
                        self.portInput.value = $0
                        guard let port = UInt16(portInput.value) else { return }
                        self.prove.address = WTAddress(ip: ipInput.value, port: port)
                    })
                    TextField(text: portBinding, prompt: Text("Port")) {
                        Text("Port")
                    }
                    .keyboardType(.numberPad)
                    .disableAutocorrection(true)
                    
                }
                
                Section {
                    Button {
                        searchState.onSuccess { (address) in
                            self.ipInput.value = address.ip
                            self.portInput.value = address.port.description
                            self.prove.address = address
                            self.prove.execute()
                        }
                        serverFinder.delegate = searchState;
                        serverFinder.beginSearch()
                    } label: {
                        HStack {
                            Text("Scan network")
                            Spacer()
                            if searchState.status == .idle {
                                PulseCircle(fill: .gray)
                            } else if (searchState.status == .searching) {
                                PulseCircle(fill: .blue, animate: true)
                            } else if searchState.status == .success {
                                PulseCircle(fill: .green, animate: true)
                            } else {
                                PulseCircle(fill: .red)
                            }
                        }
                    }
                    .foregroundColor(searchState.status == .searching ? .gray : .primary)
                    .disabled(searchState.status == .searching)
                    
                    TestConnectionButton(prove: prove, proveOnAppear: true)
                    
                    Button("Save") {
                        guard let port = UInt16(portInput.value) else { return }
                        let ip = ipInput.value
                        print("Saving", ip, port)
                        let defaults = UserDefaults.standard;
                        defaults.set(ip, forKey: UserDefaultConstants.WTServerIP)
                        defaults.set(port, forKey: UserDefaultConstants.WTServerPort)
                        wtServerService.address = WTAddress(ip: ip, port: port)
                        dismiss()
                    }
                    .foregroundColor(formDisabled ? .gray : .primary)
                    .disabled(formDisabled)
                }
                
                
            }
            .foregroundColor(.primary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .foregroundColor(.white)
        .preferredColorScheme(.dark)
    }
    
    var formDisabled: Bool {
        let ip = ipInput.value
        let port = portInput.value
        
        return ip.isEmpty || port.isEmpty || !WTAddress.validateIp(ip) || UInt16(port) == nil
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}

