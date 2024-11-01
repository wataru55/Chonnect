//
//  CompleteSignUpView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct CompleteSignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack (spacing: 10) {
            Text("Welcome to Chonnect! \(viewModel.username)")
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("ご入力ありがとうございます。下のボタンをクリックすると、ログインできます。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)

            Button(action: {
                Task { try await viewModel.createUser() }
            }, label: {
                Text("登録を完了してログイン")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding(.top)
            })
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
    }
}

#Preview {
    CompleteSignUpView()
        .environmentObject(RegistrationViewModel())
}
