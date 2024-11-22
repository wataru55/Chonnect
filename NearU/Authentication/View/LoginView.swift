//
//  LoginView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Image("Chonnect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 100)

                VStack (spacing: 15){
                    TextField("メールアドレス", text: $viewModel.email)
                        .modifier(IGTextFieldModifier())

                    SecureField("パスワード", text: $viewModel.password)
                        .modifier(IGTextFieldModifier())
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                            .padding(.horizontal, 10)
                            .transition(.opacity)
                            .animation(.easeInOut, value: errorMessage)
                    }
                } //Vstack

                Button(action: {
                    print("show forgot password")
                }, label: {
                    NavigationLink {
                        PasswordResetView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("パスワードを忘れた場合")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.systemMint))
                            .padding(.top)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .padding(.vertical, 5)

                Button(action: {
                    Task {
                        do {
                            try await viewModel.signIn() // 関数を実行
                        } catch {
                            errorMessage = "ログインに失敗しました もう一度お試しください"
                            viewModel.password = "" // パスワードをリセット
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    errorMessage = nil
                                }
                            }
                        }
                    }
                }, label: {
                    Text("ログイン")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 360, height: 44)
                        .background(Color(.systemMint))
                        .cornerRadius(12)
                        .padding(.top)
                })

                Spacer()

                Divider()

                NavigationLink {
                    //遷移先のview
                    AddEmailView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack {
                        Text("アカウントをお持ちでないですか？")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.systemMint))

                        Text("新規登録")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing))
                    }
                }
                .padding(.vertical)
            }//vstack
        }//navigationstack
    }
}

#Preview {
    LoginView()
}
