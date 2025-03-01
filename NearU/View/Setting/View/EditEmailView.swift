//
//  EditEmailView.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/28.
//

import SwiftUI

struct EditEmailView: View {
    @ObservedObject var viewModel: SettingViewModel
    @FocusState var focus: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            Text("メールアドレスの変更")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("新しいメールアドレスを入力してください\n確認メールが送信されます。")
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
                .focused(self.$focus)
                .toolbar{
                    ToolbarItem(placement: .keyboard){
                        HStack{
                            Spacer()
                            Button("閉じる"){
                                self.focus = false
                            }
                        }
                    }
                }

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
            .alert("再認証が必要です", isPresented: $viewModel.isShowAlert) {
                SecureField("パスワード", text: $viewModel.password)
                
                Button("キャンセル") {
                    viewModel.isShowAlert = false
                }
                Button("完了") {
                    viewModel.isShowAlert = false
                    Task {
                        await viewModel.reAuthAndEditEmail()
                    }
                }
            } message: {
                Text(
                    "最後にログインしてから長時間経過しています\nログイン時のパスワードを入力してください。"
                )
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

            Spacer()
        }//vstack
    }
}

#Preview {
    EditEmailView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
