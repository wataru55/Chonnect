//
//  MainTabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI
import Firebase

struct MainTabView: View {
    //MARK: - property
    let user: User

    @StateObject var centralManager = BLECentralManager.shared
    @StateObject var peripheralManager = BLEPeripheralManager.shared
    @Environment(\.scenePhase) private var scenePhase

    init(user: User) {
        self.user = user
    }

    var body: some View {
        TabView {
            SearchView(currentUser: user)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            CurrentUserProfileView(user: user)
                .tabItem {
                    Image(systemName: "person")
                    Text("MyProfile")
                }

            SettingView(user: user)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
        } //tabview
        .accentColor(Color(.systemMint))
        .onAppear {
            // 通知の許可をリクエスト
            requestNotificationAuthorization()

            peripheralManager.configure(with: user)

            if centralManager.centralManager.state == .poweredOn {
                centralManager.startScanning()
            }

            if peripheralManager.peripheralManager.state == .poweredOn {
                peripheralManager.startAdvertising()
            }
            // 通知の確認
            Task { await UserService().fetchNotifications() }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                if BLECentralManager.shared.centralManager.state == .poweredOn {
                    BLECentralManager.shared.startScanning()
                }

                if BLEPeripheralManager.shared.peripheralManager.state == .poweredOn {
                    BLEPeripheralManager.shared.startAdvertising()
                }

            case .inactive:
                BLECentralManager.shared.stopScan()
                BLEPeripheralManager.shared.stopAdvertising()
            case .background:
                if BLECentralManager.shared.centralManager.state == .poweredOn {
                    BLECentralManager.shared.startScanning()
                }

                if BLEPeripheralManager.shared.peripheralManager.state == .poweredOn {
                    BLEPeripheralManager.shared.startAdvertising()
                }
            @unknown default:
                print("Unexpected new value.")
            }
        }
    } //body

    // 通知の許可をリクエストするメソッド
    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}//view

#Preview {
    MainTabView(user: User.MOCK_USERS[0])
}

