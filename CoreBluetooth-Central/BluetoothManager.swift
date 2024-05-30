import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    @Published var message: [String] = []
    var centralManager: CBCentralManager!
    var serviceUUID: CBUUID = CBUUID(string: "C8D89CD2-E1A8-4434-B41C-3159E8CA0981")


    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Scan Started")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral Device: ", peripheral.name ?? "Unknown", peripheral.services?.first ?? "No services")

        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        print("Connected")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            if service.uuid == serviceUUID {
                print("Discovered service with UUID: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }

        print("Found \(service.characteristics?.count ?? 0) characteristics for service \(service.uuid): \(String(describing: service.characteristics))")
        
        for characteristic in service.characteristics ?? [] {
            print("Characteristic UUID: \(characteristic.uuid)")

            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error reading characteristic value: \(error!.localizedDescription)")
            return
        }

        if let value = characteristic.value {
            if let stringValue = String(data: value, encoding: .utf8) {
                print("Characteristic \(characteristic.uuid) value: \(stringValue)")
                DispatchQueue.main.async {
                    self.message.append(stringValue)
                }
            } else {
                print("Failed to decode characteristic value as UTF-8 string")
            }
        }
    }
}
