//
//  LoginView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct LoginView: View {
    //MARK: - property
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Image("Chonnect1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 150)

                VStack (spacing: 15){
                    TextField("Enter your email", text: $viewModel.email)
                        .autocapitalization(.none) //自動的に大文字にしない
                        .modifier(IGTextFieldModifier())

                    TextField("Enter your password", text: $viewModel.password)
                        .modifier(IGTextFieldModifier())
                } //Vstack

                Button(action: {
                    print("show forgot password")
                }, label: {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.systemMint))
                        .padding(.top)
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .padding(.vertical, 5)

                Button(action: {
                    Task { try await viewModel.signIn() } //関数を実行
                }, label: {
                    Text("Log in")
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
                        Text("Don't have an account?")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.systemMint))

                        Text("Sign Up")
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
