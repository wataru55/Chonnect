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

            Text("パスワード変更に使用するリンクを\n登録されているメールアドレス宛に送信します。")
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

            TextField("変更前のパスワードを入力", text: $viewModel.inputPassword)
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
                    .foregroundColor(.pink)
                    .font(.footnote)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.message = nil
                            }
                        }
                    }
            }

            Button {
                Task {
                    await viewModel.reAuthAndSendPasswordResetMail()
                    self.focus = false
                }
            } label: {
                Text(viewModel.isShowResend ? "再送信" : "送信")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(viewModel.validatePassword ? Color.mint : Color.gray)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .disabled(!viewModel.validatePassword)

            Spacer()
        }//vstack
        .onDisappear {
            viewModel.inputPassword = ""
            viewModel.inputEmail = ""
            viewModel.isShowResend = false
        }
    }
}

#Preview {
    EditPasswordView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
