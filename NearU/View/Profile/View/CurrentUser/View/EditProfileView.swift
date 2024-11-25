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
    @State private var texts: [InterestTag] = [InterestTag(id: UUID(), text: "")]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel

    let user: User

    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
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

                    EditProfileBioRowView(title: "自己紹介", placeholder: "自己紹介を入力してください", text: $viewModel.bio)
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
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.black)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try await viewModel.updateUserData()
                            await viewModel.saveInterestTags(tags: texts)
                            try await AuthService.shared.loadUserData()

                            await MainActor.run {
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
    @Binding var texts: [InterestTag]
    let interestTags: [InterestTag]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Text("興味タグ")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                    .padding(.vertical, 10)

                ForEach(texts.indices, id: \.self) { index in
                    TextField("興味のあること", text: $texts[index].text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never) // 自動で大文字にしない
                            .disableAutocorrection(true) // スペルチェックを無効にする
                            .padding(.horizontal, 15)
                            .padding(.bottom, 5)
                }

                Button {
                    texts.append(InterestTag(id: UUID(), text: ""))
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

                    InterestTagView(interestTag: interestTags, isShowDeleteButton: true)
                        .padding(.horizontal, 15)
                }
            }
        }
    }
}

struct EditProfileBioRowView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    private let characterLimit = 100 // 文字制限
    private let lineLimit = 4 // 行数制限
    private let lineHeight: CGFloat = 20 // 1行の高さ
    @State private var isOverCharacterLimit = false // 文字制限を超えたかどうか

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
    EditInterestView(texts: .constant([InterestTag(id: UUID(), text: "")]), interestTags: [InterestTag(id: UUID(), text: "SwiftUI")])
}

