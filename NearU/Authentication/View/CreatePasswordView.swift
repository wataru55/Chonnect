//
//  CreatePasswordView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct CreatePasswordView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack (spacing: 10) {
            Text("パスワードを設定")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("6文字以上20文字以内でパスワードを設定してください。\n空白は使用できません。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)
            
            SecureField("パスワード", text: $viewModel.password)
                .modifier(IGTextFieldModifier())

                
            SecureField("再入力", text: $viewModel.rePassword)
                .modifier(IGTextFieldModifier())

            Button {
                path.append(AuthPath.signUp(.emailCheck))
            } label: {
                Text(viewModel.isPasswordValid ? "次へ" : "適切なパスワードを設定してください")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(viewModel.isPasswordValid ? Color.mint : Color.gray)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .disabled(!viewModel.isPasswordValid)

            Spacer()
        }//vstack
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        viewModel.password = ""
                        viewModel.rePassword = ""
                        dismiss()
                    }
            }
        }
    }//body
}//view

#Preview {
    CreatePasswordView(path: .constant(NavigationPath()))
        .environmentObject(RegistrationViewModel())
}
