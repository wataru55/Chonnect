//
//  BluetoothManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.

import CoreBluetooth
import Foundation

//BLEデバイスをスキャンして管理するクラス
class BLECentralManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    //BLEデバイスのスキャンや接続管理をするためのインスタンス変数
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = [] //BLEデバイスのリストを保持
    var userId: String

    init(user: User) {
        self.userId = user.id
        super.init()
        //インスタンスを作成し，デリゲードをselfに設定
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    //Bluetoothの状態が変更されたときに呼び出される関数
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //central.stateプロパティで現在のBluetoothの状態を確認
        if central.state == .poweredOn {
            //BLEデバイスのスキャンを開始
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    //Bluetoothデバイスが発見されたときに呼び出される関数
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //発見されたデバイスをリストに追加
        discoveredPeripherals.append(peripheral)
        //peripheralデバイスに接続を試みる
        centralManager.connect(peripheral, options: nil)
    }

    //接続が成功した後に呼び出される関数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //peripheralのデリゲードを自信に設定
        peripheral.delegate = self
        //サービスを発見?
        peripheral.discoverServices(nil)
    }

    //BLE周辺機器（ペリフェラル）のサービスが発見されたときに呼び出される関数
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //発見されたサービスが存在するか確認
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service) //サービスの特性を発見
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
                let userIdData = userId.data(using: .utf8)!
                //変換したユーザーIDデータを特性に書き込む
                peripheral.writeValue(userIdData, for: characteristic, type: .withResponse)
            }
        }
    }

}
