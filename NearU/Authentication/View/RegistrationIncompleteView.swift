//
//  RegistrationIncompleteView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/28.
//

import SwiftUI

enum RegistrationState: Hashable {
    case completeSignUp
}

struct RegistrationIncompleteView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack (spacing: 10) {
                    Text("まだ登録が完了していません")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("メールアドレス宛に認証メールを送信します。\n送信後、確認画面が表示されます。")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom)
                    
                    if let message = viewModel.errorMessage {
                        errorMessage(text: message)
                    }
                    
                    VStack(spacing: 25) {
                        Button {
                            Task {
                                await viewModel.reSendEmailVerification()
                                await MainActor.run {
                                    viewModel.isShowCheck = true
                                }
                            }
                        } label: {
                            Text("認証メールの送信")
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
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowCheck) {
                checkWaitingView()
            }
            .navigationDestination(for: RegistrationState.self) { route in
                switch route {
                case .completeSignUp:
                    CompleteSignUpView(path: $path)
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden()
                }
            }
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
                    Task {
                        await viewModel.checkUserValidation()
                        if viewModel.isValidateUser {
                            viewModel.isShowCheck = false
                            path.append(RegistrationState.completeSignUp)
                        } else {
                            viewModel.errorMessage = "認証が完了していません"
                        }
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
                        await viewModel.reSendEmailVerification()
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
    RegistrationIncompleteView()
}
