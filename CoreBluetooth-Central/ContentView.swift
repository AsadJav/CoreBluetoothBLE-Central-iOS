//
//  ContentView.swift
//  CoreBluetooth-Central
//
//  Created by Tahir Mac aala on 30/05/2024.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    var body: some View {
        VStack {
            Text("Searching for Peripheral device...")
            List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                            Text(peripheral.name ?? "Unknown Device")
            }
            .navigationTitle("Device")
            .background(Color.white)
            List(bluetoothManager.message, id: \.self) { message in
                            Text(message)
            }
        }
    }
}

#Preview {
    ContentView()
}
