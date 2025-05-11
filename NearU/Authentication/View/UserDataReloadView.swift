//
//  UserDataReloadView.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/01.
//

import SwiftUI

struct UserDataReloadView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text("ユーザーデータの取得に失敗しました")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("通信環境の良い場所で再度お試しください")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom)
                
                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.pink)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.errorMessage)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    viewModel.errorMessage = nil
                                }
                            }
                        }
                }
                
                VStack(spacing: 25) {
                    Button {
                        Task {
                            await viewModel.loadUserData()
                        }
                    } label: {
                        Text("再読み込み")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background {
                                Capsule()
                                    .foregroundStyle(.mint)
                                    .frame(width: 350)
                            }
                    }
                    
                    Button {
                        AuthService.shared.signout()
                    } label: {
                        Text("ログイン画面へ戻る")
                            .foregroundStyle(.mint)
                            .padding(10)
                            .background {
                                Capsule()
                                    .stroke(lineWidth: 1.5)
                                    .foregroundStyle(.mint)
                                    .frame(width: 350)
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}
