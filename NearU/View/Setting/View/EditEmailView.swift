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
        ZStack {
            VStack (spacing: 10) {
                Text("メールアドレスの変更")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("新しいメールアドレスを入力してください\n確認メールが送信されます")
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

                TextField("新しいメールアドレス", text: $viewModel.inputEmail)
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
                    viewModel.sendButtonPressed()
                } label: {
                    Text("送信")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 360, height: 44)
                        .background(viewModel.validateEmail ? Color.mint : Color.gray)
                        .cornerRadius(12)
                        .padding(.top)
                }
                .disabled(!viewModel.validateEmail)
                .alert("確認", isPresented: $viewModel.isShowAlert) {
                    SecureField("パスワード", text: $viewModel.inputPassword)
                    
                    Button("キャンセル") {
                        viewModel.isShowAlert = false
                    }
                    Button("完了") {
                        viewModel.isShowAlert = false
                        Task {
                            await viewModel.reAuthAndSendEmailResetLink()
                            self.focus = false
                        }
                    }
                } message: {
                    Text(
                        "ログイン時のパスワードを\n入力してください。"
                    )
                }

                Spacer()
            }//vstack
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .onDisappear {
            viewModel.inputPassword = ""
            viewModel.inputEmail = ""
        }
        .fullScreenCover(isPresented: $viewModel.isShowCheck) {
            CheckView(viewModel: viewModel)
        }
    }
}

#Preview {
    EditEmailView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
