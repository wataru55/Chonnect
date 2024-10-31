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
            peripheralManager.configure(with: user)

            if centralManager.centralManager.state == .poweredOn {
                centralManager.startScanning()
            }

            if peripheralManager.peripheralManager.state == .poweredOn {
                peripheralManager.startAdvertising()
            }
            // FCM トークンを Firestore に保存
            if let fcmToken = UserDefaults.standard.string(forKey: "FCMToken") {
                Task { await setFCMToken(fcmToken: fcmToken) }
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

    // FCMトークンをFirestoreに保存するメソッド
    func setFCMToken(fcmToken: String) async {
        guard let documentId = AuthService.shared.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }

        let data: [String: Any] = [
            "fcmtoken": fcmToken
        ]

        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(data)
            print("Document successfully updated with FCM token")
        } catch {
            print("Error updating document: \(error)")
        }
    }

}//view

#Preview {
    MainTabView(user: User.MOCK_USERS[0])
}

