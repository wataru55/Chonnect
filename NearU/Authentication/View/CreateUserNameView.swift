//
//  CreateUserName.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct CreateUserNameView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack (spacing: 10) {
            Text("ユーザ名を設定")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("他のユーザに公開される名前です。\n20文字以内で設定してください。")
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

            TextField("ユーザ名", text: $viewModel.username)
                .modifier(IGTextFieldModifier())

            Button {
                path.append(AuthPath.signUp(.inputPassword))
            } label: {
                Text(viewModel.isUsernameValid ? "次へ" : "適切なユーザー名を入力してください")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(viewModel.isUsernameValid ? Color.mint : Color.gray)
                    .cornerRadius(12)
                    .padding(.top)
            }
            .disabled(!viewModel.isUsernameValid)

            Spacer()//上に押し上げる
        }//vstack
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        viewModel.username = ""
                        dismiss()
                    }
            }
        }//toolbar
    }//body
}//view

#Preview {
    CreateUserNameView(path: .constant(NavigationPath()))
        .environmentObject(RegistrationViewModel())
}
