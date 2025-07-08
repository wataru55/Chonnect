//
//  EditUserNameView.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/02.
//

import SwiftUI

struct EditUserNameView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 5){
                Text("ユーザーネーム")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                TextField("", text: $viewModel.userName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($isFocused)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
            }
            .padding(.top, 10)
            
            HStack {
                Text("⚠️20文字以内で入力してください")
                    .foregroundStyle(.gray)
                
                Text("(\(viewModel.userName.count)/20)")
                    .foregroundStyle(viewModel.userName.count > 20 ? Color.pink : Color.gray)
            }
            .font(.footnote)
            .fontWeight(.bold)
            
            Spacer()
            
            Group {
                if !viewModel.isUsernameValid {
                    Text("内容に誤りがあります")
                }
        
                if !viewModel.isUsernameUnique {
                    Text("内容が変更されていません")
                }
            }
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(Color.pink)
            .padding(.leading, 5)
            
            Spacer()
        }
        .background(
            backgroundColor.ignoresSafeArea()
        )
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("ユーザーネーム")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.black)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        try await viewModel.saveUserName()
                        await MainActor.run() {
                            dismiss()
                        }
                    }
                } label: {
                    Text("保存")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.isUsernameValid && viewModel.isUsernameUnique ? Color.mint : Color.gray)
                }
                .disabled(!viewModel.isUsernameValid || !viewModel.isUsernameUnique)
                .alert("Error", isPresented: Binding<Bool> (
                    get: { viewModel.alertType != nil },
                    set: { if !$0 { viewModel.alertType = nil } }
                ), presenting: viewModel.alertType) { _ in
                    Button("OK", role: .cancel) { }
                } message: { alert in
                    Text(alert.message)
                }
            }
        }
        .onAppear {
            viewModel.userName = viewModel.user.username
            isFocused = true
        }
        .onDisappear() {
            viewModel.userName = viewModel.user.username
        }
    }
}

#Preview {
    EditUserNameView()
}
