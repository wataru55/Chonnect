//
//  EditPasswordView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/02.
//

import SwiftUI

struct EditPasswordView: View {
    @ObservedObject var viewModel: SettingViewModel
    @FocusState var focus: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            Text("パスワードの変更")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("パスワードを変更するためのリンクをメールで送信します。\nメールアドレスを入力してください。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)

            TextField("メールアドレス", text: $viewModel.newEmail)
                .modifier(IGTextFieldModifier())
                .focused(self.$focus)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack{
                            Spacer()
                            Button("閉じる"){
                                self.focus = false
                            }
                        }
                    }
                }
            
            if let message = viewModel.message {
                Text(message)
                    .padding(.top, 10)
                    .foregroundColor(.black)
                    .font(.footnote)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            viewModel.message = nil
                        }
                    }
            }

            Button {
                viewModel.isShowAlert = true
            } label: {
                Text(viewModel.isShowResend ? "再送信" : "送信")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding(.top)
            }
            .alert("確認", isPresented: $viewModel.isShowAlert) {
                SecureField("パスワード", text: $viewModel.password)
                
                Button("キャンセル") {
                    viewModel.isShowAlert = false
                }
                Button("完了") {
                    viewModel.isShowAlert = false
                    Task {
                        await viewModel.reAuthAndEditPassword()
                        self.focus = false
                    }
                }
            } message: {
                Text(
                    "現在のパスワードを入力してください。"
                )
            }

            Spacer()
        }//vstack
    }
}

#Preview {
    EditPasswordView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
