//
//  ContentView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @StateObject var registrationViewModel = RegistrationViewModel()

    var body: some View {
        Group {
            if viewModel.userSession == nil {
                LoginView()
                    .environmentObject(registrationViewModel)
            } else if let currentUser = viewModel.currentUser {
                MainTabView(user: currentUser)
            } else {
                 //ログインはしているが、ユーザー情報が存在しない場合のハンドリング
                RegistrationIncompleteView()
            }

        }
    }
}

#Preview {
    ContentView()
}
