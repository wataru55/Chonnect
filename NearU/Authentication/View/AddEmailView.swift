//
//  AddEmailView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct AddEmailView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel //クラスのインスタンス化
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack (spacing: 10) {
            Text("メールアドレスを設定")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("サインインにこのメールアドレスを使用します。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            viewModel.errorMessage = nil
                        }
                    }
            }
            
            TextField("メールアドレス", text: $viewModel.email)
                .modifier(IGTextFieldModifier())

            Button {
                path.append(AuthPath.signUp(.inputUsername))
            } label: {
                Text(viewModel.isEmailValid ? "次へ" : "有効なアドレスを入力してください")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(viewModel.isEmailValid ? Color.mint : Color.gray)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .disabled(!viewModel.isEmailValid)

            Spacer() //上に押し上げるため
        }//vstack
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        viewModel.email = ""
                        dismiss()
                    }
            }
        }
    }//body
}//view

#Preview {
    AddEmailView(path: .constant(NavigationPath()))
        .environmentObject(RegistrationViewModel())
}
