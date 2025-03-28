//
//  CompleteSignUpView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct CompleteSignUpView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack (spacing: 10) {
            Text("Welcome to Chonnect! \n\(viewModel.localUserName)")
                .multilineTextAlignment(.center)
                .font(.system(size: 30, weight: .bold))
                .fontWeight(.bold)

            Text("下のボタンを押すと、登録が完了します。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical)

            Button(action: {
                Task {
                    await viewModel.registerComplete()
                }
                
            }, label: {
                Text("はじめる")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemMint))
                    .cornerRadius(12)
                    .padding(.top)
            })
        }
    }
}

#Preview {
    CompleteSignUpView(path: .constant(NavigationPath()))
        .environmentObject(RegistrationViewModel())
}
