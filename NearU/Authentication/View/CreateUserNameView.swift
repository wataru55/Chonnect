//
//  CreateUserName.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct CreateUserNameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: RegistrationViewModel //インスタンス化

    var body: some View {
        VStack (spacing: 10) {
            Text("Create username")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Pick a username for your new account. You can always charge it")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)


            TextField("Username", text: $viewModel.username)
                .autocapitalization(.none) //自動的に大文字にしない
                .modifier(IGTextFieldModifier()) //カスタムモディファイア

            NavigationLink {
                CreatePasswordView()
                    .navigationBarBackButtonHidden()
            } label: {
                Text("Next")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding(.top)
            }

            Spacer()//上に押し上げる
        }//vstack
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }//toolbar
    }//body
}//view

#Preview {
    CreateUserNameView()
        .environmentObject(RegistrationViewModel())
}
