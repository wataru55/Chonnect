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
    @StateObject private var loadingViewModel = LoadingViewModel()
    @Environment(\.scenePhase) private var scenePhase

    init(user: User) {
        self.user = user
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color(red: 0.96, green: 0.97, blue: 0.98))
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        TabView {
            SearchView(currentUser: user)
                .environmentObject(loadingViewModel)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }

            CurrentUserProfileView()
                .environmentObject(loadingViewModel)
                .tabItem {
                    Image(systemName: "person")
                }

            SettingView(user: user)
                .tabItem {
                    Image(systemName: "gear")
                }
        } //tabview
        .overlay {
            if loadingViewModel.isLoading {
                LoadingView()
            }
        }
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
            case .inactive, .background:
                print("アプリが非アクティブになったが、BLEは継続")

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

//#Preview {
//    MainTabView(user: User.MOCK_USERS[0])
//}

