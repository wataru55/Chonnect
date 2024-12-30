//
//  BluetoothManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.

import CoreBluetooth
import Foundation
import Combine

// BLEデバイスをスキャンして管理するクラス
class BLECentralManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    static let shared = BLECentralManager() // シングルトンインスタンス
    var centralManager: CBCentralManager!
    var scanningTimer: Timer?
    var cleanupTimer: Timer? // クリーンアップ用タイマー
    let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-1234567890ab")

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        startCleanupTimer()
    }

    deinit {
        // タイマーを無効化
        scanningTimer?.invalidate()
        cleanupTimer?.invalidate()
        scanningTimer = nil
        cleanupTimer = nil
        // Central Manager のデリゲートを解除
        centralManager.delegate = nil
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManager.delegate = self // デリゲートを再設定
        if central.state == .poweredOn {
            let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
            if isOnBluetooth {
                startScanning()
            }
        } else {
            stopScan()
        }
    }

    func startScanning() {
        let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
        if isOnBluetooth {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            print("start Scanning")

            scanningTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
                print("スキャンが継続中")
            })
        }
    }

    // スキャン時に周囲のペリフェラルを発見したときに呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // CBAdvertisementDataLocalNameKeyKeyを確認
        if let receivedDocumentId = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("Received userId (LocalName): \(receivedDocumentId), RSSI: \(RSSI)")
            DispatchQueue.main.async {
                // 受信したuserIdをRealmに保存
                // リアルタイムデータ
                RealmRealtimeManager.shared.storeRealtimeData(receivedUserId: receivedDocumentId, date: Date(), rssi: RSSI.intValue)
                // 履歴データ
                RealmHistoryManager.shared.storeHistoryData(receivedDocumentId, date: Date())
            }
        }
    }

    func stopScan() {
        centralManager.stopScan()
        scanningTimer?.invalidate()
        scanningTimer = nil
        print("stop Scan")
    }

    func stopCentralManagerDelegate() {
        self.stopScan()
        self.centralManager.delegate = nil
    }

    // クリーンアップタイマーの開始
    func startCleanupTimer() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                RealmRealtimeManager.shared.removeRealtimeData()
            }
        }
    }
}




