//
//  EditProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI
import PhotosUI

enum Field: Hashable {
    case title
}

struct EditProfileView: View {
    @State private var isAddingNewLink = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @StateObject var abstractLinksViewModel: AbstractLinkModel
    
    let user: User
    
    @FocusState private var focusedField: Field?
    
    init(user: User) {
        self.user = user
        _abstractLinksViewModel = StateObject(wrappedValue: AbstractLinkModel(userId: user.id))
    }
    
    var body: some View {
        VStack {
            //toolbar
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Text("Edit Profile")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        try await viewModel.updateUserData()
                        try await viewModel.updateLanguageTags()
                        try await viewModel.updateFrameworkTags()
                        try await AuthService.shared.loadUserData()
                        try await viewModel.loadLanguageTags()
                        try await viewModel.loadFrameworkTags()
                        
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }, label: {
                    Text("Done")
                        .font(.subheadline)
                        .fontWeight(.bold)
                })
            }//hstack
            .padding(.horizontal)
            
            Divider()
            //edit profile picture
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    PhotosPicker(selection: $viewModel.selectedBackgroundImage) {
                        VStack {
                            if let image = viewModel.backgroundImage {
                                image
                                    .resizable()
                                    .foregroundStyle(.white)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                BackgroundImageView(user: viewModel.user, height: 200, isGradient: false)
                            }
                            
                            Text("背景画像を変更する")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding(.bottom, 10)
                        }//vstack
                    }
                    .disabled(focusedField != nil)
                }//vstack
                //edit profile info
                VStack (spacing:0){
                    Text("言語")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                        .foregroundColor(Color.gray)
                    EditLanguageTagsView(selectedLanguageTags: $viewModel.selectedLanguageTags, userId: viewModel.user.id)
                    Text("フレームワーク・ライブラリ")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                        .foregroundColor(Color.gray)
                    EditFrameworkTagsView(selectedFrameworkTags: $viewModel.selectedFrameworkTags, userId: viewModel.user.id)
                        .padding(.bottom, 10)
                    EditProfileRowView(title: "ニックネーム", placeholder: "", text: $viewModel.username)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "本名(公開したくない場合は空欄にしてください)", placeholder: "", text: $viewModel.fullname)
                        .focused($focusedField, equals: .title)
                    EditProfileBioRowView(title: "自己紹介", placeholder: "自己紹介を入力してください", text: $viewModel.bio)
                        .focused($focusedField, equals: .title)
                }
                .padding(.top, 5)
            } //scrollview
        }//vstack
        .onTapGesture {
            focusedField = nil
        }
    }//body
}//view

struct EditProfileRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack (spacing:10){
            Text(title)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            
            VStack {
                TextField(placeholder, text: $text)
                    .padding(.leading, 5)
                
                Divider()
            }//vstack
        }//hstack
        .font(.subheadline)
        .padding(5)
    }//body
}//view

struct EditProfileBioRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    private let characterLimit = 150 // 文字制限
    private let lineLimit = 5 // 行数制限
    private let lineHeight: CGFloat = 27 // 1行の高さ
    
    var body: some View {
        VStack {
            Text(title)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.gray)
            
            VStack {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                            .padding(.top, 8)
                    }
                    
                    TextEditor(text: $text)
                        .frame(minHeight: lineHeight * CGFloat(lineLimit), maxHeight: lineHeight * CGFloat(lineLimit)) // 高さを5行分に設定
                        .padding(.horizontal, 5)
                        .onChange(of: text) {enforceTextLimit()}
                }
                Divider()
            }
        }
        .font(.subheadline)
        .padding(5)
    }
    
    private func enforceTextLimit() {
        let lines = text.components(separatedBy: "\n")
        // 行数制限を超えた場合、制限内の行のみを保持
        if lines.count > lineLimit {
            text = lines.prefix(lineLimit).joined(separator: "\n")
        }
        // 文字数制限を超えた場合、制限内の文字のみを保持
        if text.count > characterLimit {
            text = String(text.prefix(characterLimit))
        }
    }
}


