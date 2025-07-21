//
//  SearchView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import SwiftUI

struct SearchView: View {
    @StateObject var historyManager = HistoryManager()
    @AppStorage("isOnBluetooth") var isOnBluetooth: Bool = true
    @State private var searchText: String = ""
    @State private var pendingToggle = false
    @State private var isShowAlert = false
    
    let currentUser: User
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 上部にChonnectの画像
                HStack {
                    Image("Chonnect")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 40)
                    
                    Spacer()
                    
                    HStack {
                        Text("通信: \(isOnBluetooth ? "ON" : "OFF")")
                            .font(.footnote)
                            .fontWeight(.bold)
                        
                        Button {
                            if isOnBluetooth {
                                pendingToggle = true
                                isShowAlert = true
                            } else {
                                isOnBluetooth = true
                            }
                        } label: {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title3)
                                .foregroundStyle(isOnBluetooth ? .mint : .gray)
                        }
                        .alert("確認", isPresented: $pendingToggle) {
                            Button("キャンセル", role: .cancel) {
                                pendingToggle = false
                            }
                            Button("OFF", role: .destructive) {
                                isOnBluetooth = false
                                pendingToggle = false
                            }
                        } message: {
                            Text("OFFにすると、他のユーザーと通信できなくなります。")
                        }
                        .onChange(of: isOnBluetooth) {
                            if isOnBluetooth {
                                BLECentralManager.shared.centralManagerDidUpdateState(BLECentralManager.shared.centralManager)
                                BLEPeripheralManager.shared.peripheralManagerDidUpdateState(BLEPeripheralManager.shared.peripheralManager)
                            } else {
                                BLECentralManager.shared.stopCentralManagerDelegate()
                                BLEPeripheralManager.shared.stopPeripheralManagerDelegate()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // 検索バー
//                TextField("Search...", text: $searchText)
//                    .padding(10)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//                    .padding(.horizontal)
                
                // コンテンツ
                VStack {
                    TopTabView(currentUser: currentUser)
                }
            }
            .navigationBarHidden(true) // デフォルトのナビゲーションバーを非表示
            .navigationDestination(for: UserDatePair.self) { pairData in
                ProfileView(user: pairData.user, currentUser: currentUser, date: pairData.date, // 日付は仮
                            isShowFollowButton: true, isShowDateButton: true)
            }
        }
        .tint(.black)
    }
}

#Preview {
    SearchView(currentUser: User.MOCK_USERS[0])
}
