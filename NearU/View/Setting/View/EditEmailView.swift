//
//  EditEmailView.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/28.
//

import SwiftUI

struct EditEmailView: View {
    @ObservedObject var viewModel: SettingViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Text("メールアドレスの変更")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("新しいメールアドレスを入力してください。\n確認メールが送信されます。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)
            
            Text("現在のメールアドレス：\(viewModel.currentEmail)")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding(.horizontal, 24)
                .padding(.bottom)


            TextField("メールアドレス", text: $viewModel.newEmail)
                .modifier(IGTextFieldModifier())

            Button {
                Task {
                    await viewModel.editEmail()
                }
            } label: {
                Text("送信")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding(.top)
            }
            
            if viewModel.isShowMessage {
                Text("アドレスに確認メールが送信されました。")
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            viewModel.isShowMessage = false
                        }
                    }
            }

            Spacer() //上に押し上げるため
        }//vstack
    }
}

#Preview {
    EditEmailView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
