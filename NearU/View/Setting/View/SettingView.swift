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
                Section(header: Text("Bluetooth")) {
                    Toggle(isOn: $isOnBluetooth) {
                        Text("Bluetooth")
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

                Section(header: Text("Private mode")) {
                    Toggle(isOn: $viewModel.isPrivate) {
                        Text("account private")
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
                      Text("Wataru Takahashi")
                    }
                    HStack {
                      Text("Version").foregroundStyle(Color.gray)
                      Spacer()
                      Text("1.0.0")
                    }
                  }
            }
            .navigationTitle("Setting")
        }//navigaiton
    }//body
}//view

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
