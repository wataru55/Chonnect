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
                
            } else if registrationViewModel.isRegisterProcessing {
                //ログインはしているが、ユーザー情報が存在しない場合のハンドリング
                RegistrationIncompleteView()
                
            } else if let currentUser = viewModel.currentUser {
                MainTabView(user: currentUser)
                
            } else {
                UserDataReloadView()
                    .environmentObject(registrationViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
