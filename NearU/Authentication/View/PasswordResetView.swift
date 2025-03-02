//
//  PasswordResetView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/25.
//

import SwiftUI

struct PasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PasswordResetViewModel()
    @State private var message: String? = nil
    @State private var showSendButton: Bool = true
    @State private var showResendButton: Bool = false
    
    var body: some View {
        VStack (spacing: 10) {
            Text("パスワードの再設定")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("パスワードを再設定するためのリンクをメールで送信します。")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom)
            
            TextField("メールアドレス", text: $viewModel.email)
                .modifier(IGTextFieldModifier())
            
            if let message = message {
                Text(message)
                    .foregroundColor(.black)
                    .font(.footnote)
                    .padding(.top)
                    .transition(.opacity)
            }
            
            // 送信ボタン
            if showSendButton {
                Button(action: {
                    showSendButton = false
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            message = "リセット用のリンクを送信しました。"
                            showResendButton = true
                        } catch {
                            message = "エラーが発生しました。もう一度お試しください。"
                            showSendButton = true
                        }
                    }
                }, label: {
                    Text("送信")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 360, height: 44)
                        .background(Color.mint)
                        .cornerRadius(12)
                        .padding(.top)
                })
            }
            
            // 再送信ボタン
            if showResendButton {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            message = "リセット用のリンクを再送信しました。"
                        } catch {
                            message = "再送信に失敗しました。もう一度お試しください。"
                        }
                    }
                }, label: {
                    Text("再送信")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 360, height: 44)
                        .background(Color.mint)
                        .cornerRadius(12)
                        .padding(.top)
                })
            }
            
            Spacer()
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
    PasswordResetView()
}


