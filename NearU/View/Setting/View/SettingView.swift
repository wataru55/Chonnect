//
//  SettingView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/27.
//

import SwiftUI

struct SettingView: View {
    @StateObject var viewModel : SettingViewModel
    @State private var isOnBluetooth: Bool = UserDefaults.standard.bool(forKey: "isOnBluetooth")

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: SettingViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
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

                }
                
                AppInfo()

            }
            .navigationTitle("設定")
            .toolbarBackground(Color.mint, for: .navigationBar)
        }//navigaiton
    }//body
    
    private func AppInfo() -> some View {
        Section(header: Text("Application")) {
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
            
            HStack {
                Spacer()
                Button(action: {
                    AuthService.shared.signout()
                }, label: {
                    Text("Log out")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .frame(width: 200, height: 44)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.gray)
                        )
                })
                Spacer()
            }//hstack
            .padding(.top)
        }
    }
}//view

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
