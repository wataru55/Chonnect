//
//  BluetoothManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.

import CoreBluetooth
import Foundation

//BLEデバイスをスキャンして管理するクラス
class BLECentralManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLECentralManager() //シングルトンインスタンス
    //BLEデバイスのスキャンや接続管理をするためのインスタンス変数
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = [] //BLEデバイスのリストを保持
    var userId: String?
    var scanningTimer: Timer? // 定期的な出力用のタイマーを追加

    let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-1234567890ab")
    let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-9876543210ba")

    private override init() {
        //self.userId = user.id
        super.init()
        //インスタンスを作成し，デリゲードをselfに設定
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func configure(with user: User) {
        self.userId = user.id
    }

    //Bluetoothの状態が変更されたときに呼び出される関数
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
            if isOnBluetooth {
                startScanning()
            }
        } else {
            stopScan()
        }
    }

    //Bluetoothデバイスが発見されたときに呼び出される関数
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //発見されたデバイスをリストに追加
        discoveredPeripherals.append(peripheral)
        //peripheralデバイスに接続を試みる
        centralManager.connect(peripheral, options: nil)
        //peripheral.discoverServices([serviceUUID])
    }

    //接続が成功した後に呼び出される関数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //peripheralのデリゲードを自信に設定
        peripheral.delegate = self
        //サービスを発見する
        peripheral.discoverServices([serviceUUID])
    }

    //BLE周辺機器（ペリフェラル）のサービスが発見されたときに呼び出される関数
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //発見されたサービスが存在するか確認
        guard let services = peripheral.services else { return }
        for service in services {
            //サービスの特性を発見
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    //BLE周辺機器の特性が発見されたときに呼び出される関数
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //特性の発見に成功しているか確認
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            //特性のプロパティをチェックし、その特性が書き込み可能であるかを確認
            if characteristic.properties.contains(.write) {
                //ユーザーIDをUTF-8エンコードのデータ形式に変換
                if let userId = userId {
                    let userIdData = userId.data(using: .utf8)!
                    //変換したユーザーIDデータを特性に書き込む
                    peripheral.writeValue(userIdData, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    //バックグラウンド時に呼び出される関数
    func startScanning() {
        let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
        if isOnBluetooth {
            centralManager.scanForPeripherals(withServices: [serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            print("start Scanning")

            scanningTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
                print("スキャンが継続中")
            })
        }
    }

    func stopScan() {
        centralManager.stopScan()
        print("stop Scan")
    }

    func stopCentralManagerDelegate() {
        self.stopScan()
        self.centralManager.delegate = nil
    }

}
