//
//  NearUApp.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    //アプリケーションの起動時に呼び出されるメソッド
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }

    //アプリケーションがバックグラウンドに移行する直前に呼ばれる
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
        BLECentralManager.shared.stopScan()
        BLEPeripheralManager.shared.stopAdvertising()

        if BLECentralManager.shared.centralManager.state == .poweredOn {
            BLECentralManager.shared.startScanning()
        }

        if BLEPeripheralManager.shared.peripheralManager.state == .poweredOn {
            BLEPeripheralManager.shared.startAdvertising()
        }

    }

    // アプリケーションがフォアグラウンドに移行する直前に呼ばれる
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("foreground")
        if BLECentralManager.shared.centralManager.state == .poweredOn {
            BLECentralManager.shared.startScanning()
        }

        if BLEPeripheralManager.shared.peripheralManager.state == .poweredOn {
            BLEPeripheralManager.shared.startAdvertising()
        }
    }
}

@main
struct NearUApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
