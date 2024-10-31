//
//  AddEmailView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct AddEmailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: RegistrationViewModel //クラスのインスタンス化

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


            TextField("メールアドレス", text: $viewModel.email)
                .modifier(IGTextFieldModifier())

            NavigationLink {
                CreateUserNameView()
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

            Spacer() //上に押し上げるため
        }//vstack
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }//body
}//view

#Preview {
    AddEmailView()
        .environmentObject(RegistrationViewModel())
}
