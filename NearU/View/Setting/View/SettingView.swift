//
//  SettingView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/27.
//

import SwiftUI

struct SettingView: View {
    @StateObject var viewModel : SettingViewModel

    @State private var isOnBluetooth: Bool = true

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
                }

                Section(header: Text("Private mode")) {
                    Toggle(isOn: $viewModel.isPrivate) {
                        Text("account private")
                    }
                    .onChange(of: viewModel.isPrivate) {
                        Task { try await viewModel.updateIsPrivate() }
                    }
                }
            }
        }
        .navigationTitle("Setting")
    }
}

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
