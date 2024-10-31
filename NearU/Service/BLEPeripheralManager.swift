//
//  BLEPeripheralManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/28.
//
import CoreBluetooth
import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import Combine

// デバイスがペリフェラルとしてデータを提供するためのクラス
class BLEPeripheralManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    static let shared = BLEPeripheralManager() // シングルトンインスタンス
    var peripheralManager: CBPeripheralManager!
    var documentId: String?
    var advertisingTimer: Timer?

    private override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func configure(with user: User) {
        self.documentId = user.id
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
            if isOnBluetooth {
                startAdvertising()
            }
        } else {
            stopAdvertising()
        }
    }

    func startAdvertising() {
        let isOnBluetooth = UserDefaults.standard.bool(forKey: "isOnBluetooth")
        if isOnBluetooth {
            guard let documentId = self.documentId else { return }

            // アドバタイズデータに常にuserIdをLocalNameとして設定
            let advertisementData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "12345678-1234-1234-1234-1234567890ab")],
                CBAdvertisementDataLocalNameKey: documentId
            ]

            peripheralManager.startAdvertising(advertisementData)
            print("start Advertising")

            advertisingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                if self.peripheralManager.isAdvertising {
                    print("アドバタイズが継続中")
                } else {
                    print("アドバタイズが停止しています")
                }
            }
        }
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        advertisingTimer?.invalidate()
        advertisingTimer = nil
        print("stop Advertising")
    }

    func stopPeripheralManagerDelegate() {
        self.stopAdvertising()
        self.peripheralManager.delegate = nil
    }
}






