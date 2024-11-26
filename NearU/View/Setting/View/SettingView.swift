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
                Section(header: Text("近くのユーザーがあなたのプロフィールを閲覧できます")) {
                    Toggle(isOn: $isOnBluetooth) {
                        Text("BLE通信")
                    }
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

                Section(header: Text("SNSリンクへのアクセスを相互フォローに限定します")) {
                    Toggle(isOn: $viewModel.isPrivate) {
                        Text("SNSのアクセス制限")
                    }
                    .onChange(of: viewModel.isPrivate) {
                        Task { try await viewModel.updateIsPrivate() }
                    }
                }


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
                            Spacer() // 左のスペーサー
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
                            Spacer() // 右のスペーサー
                    }//hstack
                    .padding(.top)
                  }
            }
            .navigationTitle("Setting")
        }//navigaiton
    }//body
}//view

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
