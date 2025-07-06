//
//  EditBioView.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/02.
//

import SwiftUI

struct EditBioView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 5){
                Text("自己紹介")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                TextField("", text: $viewModel.bio, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .multilineTextAlignment(TextAlignment.leading)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .autocorrectionDisabled(true)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
            }
            .padding(.top, 10)
            
            HStack {
                Text("⚠️100文字以内で入力してください")
                    .foregroundStyle(.gray)
                
                Text("\(viewModel.bio.count)/100")
                    .foregroundStyle(viewModel.bio.count > 100 ? .pink : .gray)
            }
            .font(.footnote)
            .fontWeight(.bold)
            
            Spacer()
            
            Group {
                if !viewModel.isBioValid {
                    Text("内容に誤りがあります")
                }
        
                if !viewModel.isBioUnique {
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
        .navigationTitle("自己紹介")
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
                        try await viewModel.saveBio()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                } label: {
                    Text("保存")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.isBioValid && viewModel.isBioUnique ? Color.mint : Color.gray)
                }
                .disabled(!viewModel.isBioValid || !viewModel.isBioUnique)
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
            viewModel.bio = viewModel.user.bio ?? ""
            isFocused = true
        }
        .onDisappear() {
            viewModel.bio = viewModel.user.bio ?? ""
        }
    }
}

#Preview {
    EditBioView()
}
