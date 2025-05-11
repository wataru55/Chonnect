//
//  DeleteView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/04.
//

import SwiftUI

struct DeleteView: View {
    @ObservedObject var viewModel: SettingViewModel
    @FocusState var focus: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .scaleEffect(1.5)
                .foregroundStyle(.pink)
                .padding(.bottom, 10)
            
            Text("退会手続き")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            VStack {
                Text("退会後、あなたの情報は全て削除されます。\n退会後にデータを復元することはできません。")
                
                Text("退会を望まれる場合は、ログイン時のパスワードを\n入力してください。")
            }
            .frame(width: 300)
            .font(.footnote)
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom)
            
            TextField("パスワード", text: $viewModel.inputPassword)
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
                self.focus = false
                viewModel.isShowAlert = true
            } label: {
                Text("退会")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color.pink)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .alert("最終確認", isPresented: $viewModel.isShowAlert) {
                Button("キャンセル", role: .cancel) {
                    viewModel.isShowAlert = false
                }
                Button("退会", role: .destructive) {
                    viewModel.isShowAlert = false
                    
                    Task {
                        await viewModel.deleteUser()
                    }
                }
            } message: {
                Text(
                    "退会処理を実行します。\n本当によろしいですか？"
                )
            }

            Spacer()
        }//vstack
        .onDisappear {
            viewModel.inputPassword = ""
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}

#Preview {
    DeleteView(viewModel: SettingViewModel(user: User.MOCK_USERS[0]))
}
