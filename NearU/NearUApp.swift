//
//  NearUApp.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseCore
import FirebaseAppCheck
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
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

        // FCMトークンの取得やFirebaseのメッセージング関連のイベントをこのクラスで処理
        Messaging.messaging().delegate = self

        // アプリがフォアグラウンドで通知を受け取ったときの処理をこのクラスで行う
        UNUserNotificationCenter.current().delegate = self

        // Push通知許可のポップアップを表示
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        return true
    }

    // テスト通知に必要なFCMトークンを出力する
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken called")
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                // UserDefaultsにFCMトークンを保存
                UserDefaults.standard.set(token, forKey: "FCMToken")
                // 保存が正常に完了したことを確認
                if let savedToken = UserDefaults.standard.string(forKey: "FCMToken") {
                    if savedToken == token {
                        print("FCM token successfully saved to UserDefaults.")
                    } else {
                        print("FCM token saved to UserDefaults does not match the original token.")
                    }
                } else {
                    print("Failed to retrieve FCM token from UserDefaults after saving.")
                }
            }
        }
    }

    // Push通知の登録に失敗した場合に呼ばれる
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
            print("MessageID: \(messageID)")
        }
        print(userInfo)
        completionHandler(.newData)
    }

    // FCMトークンを受け取るデリゲートメソッド
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("messaging(_:didReceiveRegistrationToken:) called with token: \(fcmToken)")
        // UserDefaultsにFCMトークンを保存
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
        // 保存が正常に完了したことを確認
        if let savedToken = UserDefaults.standard.string(forKey: "FCMToken") {
            if savedToken == fcmToken {
                print("FCM token successfully saved to UserDefaults.")
            } else {
                print("FCM token saved to UserDefaults does not match the original token.")
            }
        } else {
            print("Failed to retrieve FCM token from UserDefaults after saving.")
        }

        // 必要に応じてトークンをサーバーに送信
    }


    // アプリがForeground時にPush通知を受信する処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // アプリケーションがバックグラウンドに移行する直前に呼ばれる
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
            LaunchScreen()
        }
    }
}
