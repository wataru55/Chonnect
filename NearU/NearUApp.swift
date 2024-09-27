//
//  NearUApp.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: UIResponder, UIApplicationDelegate {
    //アプリケーションの起動時に呼び出されるメソッド
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // プロバイダファクトリの宣言
        let providerFactory: AppCheckProviderFactory

        // ビルド設定に応じてプロバイダを切り替え
        #if DEBUG
        providerFactory = AppCheckDebugProviderFactory()
        #else
        if #available(iOS 14.0, *) {
            providerFactory = AppAttestProviderFactory()
        } else {
            providerFactory = DeviceCheckProviderFactory()
        }
        #endif

        // App Checkのプロバイダを設定
        AppCheck.setAppCheckProviderFactory(providerFactory)

        // Firebaseの初期化
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
