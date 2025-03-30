//
//  EmailCheckView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/25.
//

import SwiftUI

struct EmailCheckView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text("メールアドレス認証のお願い")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("入力いただいたメールアドレスに認証メールを送信します。\n送信後、確認画面が表示されます。")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom)
                
                if let message = viewModel.errorMessage {
                    errorMessage(text: message)
                }
                
                Button {
                    viewModel.isLoading = true
                    UserDefaults.standard.setValue(viewModel.username, forKey: "username")
                    Task {
                        try await viewModel.createUserToAuth()
                        try await viewModel.sendValidationEmail()
                        await MainActor.run {
                            viewModel.isLoading = false
                            viewModel.isShowCheck = true
                        }
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
                
                Spacer()
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowCheck) {
            checkWaitingView()
        }
    }
    
    private func checkWaitingView() -> some View {
        ZStack {
            VStack(spacing: 25) {
                Text("認証メールを送信しました")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("入力いただいたメールアドレスに届いた認証リンクをクリックしてください。メール認証を終えたら、再度この画面に戻り「確認完了」ボタンを押してください。")
                    .frame(width: 350)
                    .font(.footnote)
                    .padding(.bottom, 20)
                
                if let message = viewModel.errorMessage {
                    errorMessage(text: message)
                }
                
                Button {
                    if viewModel.isValidateUser {
                        viewModel.isShowCheck = false
                        path.append(AuthPath.signUp(.completeSignUp))
                    } else {
                        viewModel.errorMessage = "認証が完了していません"
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
                    viewModel.isLoading = true
                    Task {
                        try await viewModel.sendValidationEmail()
                        await MainActor.run {
                            viewModel.isLoading = false
                        }
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
                    Task {
                        try await viewModel.deleteAuth()
                        await MainActor.run {
                            viewModel.inputReset()
                            path.removeLast(path.count)
                        }
                    }
                } label: {
                    Text("最初からやり直す")
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
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
    
    private func errorMessage(text: String) -> some View {
        Text(text)
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
}

#Preview {
    EmailCheckView(path: .constant(NavigationPath()))
}
