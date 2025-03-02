//
//  CheckView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/02.
//

import SwiftUI

struct CheckView: View {
    @ObservedObject var viewModel: SettingViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            Text("認証メールを送信しました")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("入力いただいたメールアドレスに届いた認証リンクをクリックしてください。メール認証を終えたら、再度この画面に戻り「確認完了」ボタンを押してください。")
                .frame(width: 350)
                .font(.footnote)
                .padding(.bottom, 20)
            
            Button {
                Task {
                    await viewModel.checkComplete()
                }
            } label: {
                Text("確認完了")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background {
                        Capsule()
                            .foregroundStyle(.mint)
                            .frame(width: 350)
                    }
            }

            Button {
                Task {
                    await viewModel.reAuthAndEditEmail()
                }
            } label: {
                Text("メールを再送する")
                    .foregroundStyle(.mint)
                    .padding(10)
                    .background {
                        Capsule()
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(.mint)
                            .frame(width: 350)
                    }
            }
            
            Button {
                viewModel.newEmail = ""
                viewModel.password = ""
                viewModel.isShowCheck = false
            } label: {
                Text("やり直す")
                    .foregroundStyle(.mint)
                    .padding(10)
                    .background {
                        Capsule()
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(.mint)
                            .frame(width: 350)
                    }
            }
            
            if let message = viewModel.message {
                Text(message)
                    .padding(.top, 10)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            viewModel.message = nil
                        }
                    }
            }
            
        }
    }
}

#Preview {
    CheckView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
