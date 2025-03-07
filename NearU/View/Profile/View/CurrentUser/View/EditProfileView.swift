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
    @State private var isLoading = false
    @State private var texts = [""]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @FocusState private var focusedField: Field?

    let user: User
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        PhotosPicker(selection: $viewModel.selectedBackgroundImage) {
                            VStack {
                                if let image = viewModel.backgroundImage {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.white)
                                        .frame(width: UIScreen.main.bounds.width - 20, height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    BackgroundImageView(user: viewModel.user, height: 250, isGradient: false)
                                }

                                Text("背景画像を変更する")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.mint)
                                    .padding(.bottom, 10)
                            }//vstack
                        }
                        .disabled(focusedField != nil)
                    }//vstack
                    //edit profile info
                    VStack (spacing:0){
                        EditProfileRowView(title: "ニックネーム", placeholder: "", text: $viewModel.username)
                            .focused($focusedField, equals: .title)

                        EditProfileBioRowView( text: $viewModel.bio, title: "自己紹介", placeholder: "")
                            .focused($focusedField, equals: .title)

                        EditInterestView(texts: $texts, interestTags: viewModel.interestTags)
                            .focused($focusedField, equals: .title)
                    }
                    .padding(.top, 5)
                } //scrollview
                .onTapGesture {
                    focusedField = nil
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("プロフィール編集")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.resetSelectedImage()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.black)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isLoading = true
                            
                            Task {
                                defer {
                                    Task { @MainActor in
                                        isLoading = false
                                    }
                                }
                                
                                try await viewModel.updateUserData()
                                try await AuthService.shared.loadUserData()

                                await MainActor.run {
                                    viewModel.resetSelectedImage()
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle")
                                Text("保存")
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.mint)
                        }
                    }
                }
                
                if isLoading {
                    LoadingView()
                }
            }// zstack
            .modifier(EdgeSwipe())
        }//navigationstack
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
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .autocorrectionDisabled(true)

                Divider()
            }//vstack
        }//hstack
        .font(.subheadline)
        .padding(5)
    }//body
}//view

struct EditInterestView: View {
    @Binding var texts: [String]
    let interestTags: [String]

    var body: some View {
        VStack(spacing: 0) {
            Text("興味タグ")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                .padding(.vertical, 10)

            ForEach(texts.indices, id: \.self) { index in
                TextField("興味・関心", text: $texts[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never) // 自動で大文字にしない
                    .disableAutocorrection(true) // スペルチェックを無効にする
                    .font(.subheadline)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
            }

            Button {
                texts.append("")
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                        .offset(y: 3)
                    Text("入力欄を追加")
                        .padding(.top, 5)
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(Color.mint)
            }
            .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 0) {
                Text("一覧")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()

                if interestTags.isEmpty{
                    Text("興味タグがありません")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                        .padding(.leading, 15)
                } else {
                    InterestTagView(interestTag: interestTags, isShowDeleteButton: true, textFont: .footnote)
                        .padding(.horizontal, 15)
                }
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        }
    }
}

struct EditProfileBioRowView: View {
    @State private var isOverCharacterLimit = false // 文字制限を超えたかどうか
    @Binding var text: String
    let title: String
    let placeholder: String
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    private let characterLimit = 100 // 文字制限
    private let lineLimit = 4 // 行数制限
    private let lineHeight: CGFloat = 20 // 1行の高さ

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.gray)

                // 文字制限を超えている場合
                if isOverCharacterLimit {
                    Text("自己紹介は100字以内で入力してください")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                            .padding(.top, 8)
                    }

                    TextEditor(text: $text)
                        .frame(minHeight: lineHeight * CGFloat(lineLimit), maxHeight: lineHeight * CGFloat(lineLimit))
                        .padding(.horizontal, 5)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled(true)
                        .scrollContentBackground(.hidden)
                        .background(backgroundColor)
                        .onChange(of: text) {
                            enforceTextLimit()
                        }
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

        // 文字数制限を超えたかどうかを確認して超えている場合に切り捨てる
        if text.count > characterLimit {
            text = String(text.prefix(characterLimit))
            isOverCharacterLimit = true
        } else {
            isOverCharacterLimit = false
        }
    }
}

#Preview {
    EditInterestView(texts: .constant([""]), interestTags: ["SwiftUI"])
}

