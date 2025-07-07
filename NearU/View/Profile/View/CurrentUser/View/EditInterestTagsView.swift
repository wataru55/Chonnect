//
//  EditInterestTagsView.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/02.
//

import SwiftUI

struct EditInterestTagsView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 5){
                Text("興味・関心")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                Text("興味のある分野やトピックを追加しましょう")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                    .padding(.vertical, 5)
                
                ForEach($viewModel.interestTags.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        TextField("興味・関心", text: $viewModel.interestTags[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($isFocused)
                            .font(.subheadline)
                        
                        Button {
                            viewModel.deleteTag(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.black)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                Button {
                    if viewModel.interestTags.count < 10 {
                        viewModel.interestTags.insert("", at: viewModel.interestTags.count)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("入力欄を追加")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(viewModel.interestTags.count < 10 ? Color.mint : Color.gray)
                    .padding(.vertical, 5)
                }
                
                HStack {
                    Text("⚠️")
                        .font(.footnote)
                    
                    VStack(alignment: .leading) {
                        Text("1文字以上、20文字以内で入力してください。")
                            .foregroundStyle(.gray)
                            .font(.caption)
                        
                        HStack {
                            Text("10個まで追加できます")
                                .foregroundStyle(.gray)
                                .font(.caption)
                            
                            Text("(\(viewModel.interestTags.count)/10)")
                                .foregroundStyle(viewModel.interestTags.count > 10 ? Color.pink : Color.gray)
                                .font(.caption)
                        }
                    }
                }
                .fontWeight(.bold)
                .padding(.vertical, 10)
            }
            .padding(.top, 10)
            
            Spacer()
            
            Group {
                if !viewModel.isInterestTagsValid {
                    Text("内容に誤りがあります")
                }
        
                if !viewModel.isInterestTagsUnique {
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
        .navigationTitle("興味タグ")
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
                    
                } label: {
                    Text("保存")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.isInterestTagsValid && viewModel.isInterestTagsUnique ? Color.mint : Color.gray)
                }
                .disabled(!viewModel.isInterestTagsValid || !viewModel.isInterestTagsUnique)
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
            viewModel.interestTags = viewModel.user.interestTags
            viewModel.interestTags.insert("", at: viewModel.interestTags.count)
            isFocused = true
        }
        .onDisappear() {
            viewModel.interestTags = []
        }
    }
}

#Preview {
    EditInterestTagsView()
}
