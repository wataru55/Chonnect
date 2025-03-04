//
//  SettingView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/27.
//

import SwiftUI

struct SettingView: View {
    @StateObject var viewModel : SettingViewModel
    @State private var isShowAlert: Bool = false
    @State private var isOnBluetooth: Bool = UserDefaults.standard.bool(forKey: "isOnBluetooth")

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: SettingViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("近くのユーザーとのプロフィール交換を可能にする")) {
                        Toggle(isOn: $isOnBluetooth) {
                            Text("BLE通信")
                        }
                        .tint(.mint)
                        .onChange(of: isOnBluetooth) {
                            UserDefaults.standard.set(isOnBluetooth, forKey: "isOnBluetooth")
                            if isOnBluetooth {
                                BLECentralManager.shared.centralManagerDidUpdateState(BLECentralManager.shared.centralManager)
                                BLEPeripheralManager.shared.peripheralManagerDidUpdateState(BLEPeripheralManager.shared.peripheralManager)
                            } else {
                                BLECentralManager.shared.stopCentralManagerDelegate()
                                BLEPeripheralManager.shared.stopPeripheralManagerDelegate()
                            }
                        }
                    }

                    Section(header: Text("SNSリンクへのアクセスを相互フォローに限定")) {
                        Toggle(isOn: $viewModel.isPrivate) {
                            Text("SNSのアクセス制限")
                        }
                        .tint(.mint)
                        .onChange(of: viewModel.isPrivate) {
                            Task { try await viewModel.updateIsPrivate() }
                        }
                    }
                    
                    Section(header: Text("ブロックしたユーザーの確認および解除")) {
                        NavigationLink {
                            BlockListView()
                        } label: {
                            Text("ブロック一覧")
                        }
                    }
                    
                    Section(header: Text("ログイン情報の変更")) {
                        NavigationLink {
                            EditEmailView(viewModel: viewModel)
                        } label: {
                            Text("メールアドレス変更")
                        }
                        
                        NavigationLink {
                            EditPasswordView(viewModel: viewModel)
                        } label: {
                            Text("パスワード変更")
                        }
                    }
                    
                    AppInfo()
                    
                    Section(header: Text("ログアウト・退会")) {
                        Button {
                            isShowAlert = true
                        } label: {
                            Text("ログアウト")
                                .foregroundStyle(.pink)
                        }
                        
                        NavigationLink {
                            DeleteView(viewModel: viewModel)
                        } label: {
                            Text("退会")
                        }
                    }
                }
                .navigationTitle("設定")
                .toolbarBackground(Color.mint, for: .navigationBar)
            }
            .alert("確認", isPresented: $isShowAlert) {
                Button("キャンセル", role: .cancel) {
                    isShowAlert = false
                }
                Button("ログアウト", role: .destructive) {
                    isShowAlert = false
                    AuthService.shared.signout()
                }
            } message: {
                Text(
                    "ログアウトしますか？"
                )
            }
            
        }//navigaiton
    }//body
    
    private func AppInfo() -> some View {
        Section(header: Text("このアプリについて")) {
            HStack {
                Text("Product").foregroundStyle(Color.gray)
                Spacer()
                Text("Chonnect")
            }
            HStack {
                Text("Compatibility").foregroundStyle(Color.gray)
                Spacer()
                Text("iPhone")
            }
            HStack {
                Text("Developer").foregroundStyle(Color.gray)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Wataru Takahashi")
                    Text("Tsubasa Watanabe")
                    Text("Ukyo Taniguchi")
                }
            }
            HStack {
                Text("Version").foregroundStyle(Color.gray)
                Spacer()
                Text("1.0.0")
            }
        }
    }
}//view

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
