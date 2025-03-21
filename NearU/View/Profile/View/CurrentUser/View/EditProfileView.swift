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

    //let user: User
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        editBackgroundImage()
                        
                        editUserName()

                        editBio()

                        editInterestTags()
                    }//vstack
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
                                
                                await viewModel.updateUserData(addTags: texts)

                                await MainActor.run {
                                    if let currentUser = AuthService.shared.currentUser {
                                        viewModel.user = currentUser
                                    }
                                    viewModel.resetSelectedImage()
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 2) {
                                if viewModel.isAbleToSave {
                                    Image(systemName: "checkmark.circle")
                                }
                                Text("保存")
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(viewModel.isAbleToSave ? Color.mint : Color.gray)
                        }
                        .disabled(!viewModel.isAbleToSave)
                    }
                }
                
                if isLoading {
                    LoadingView()
                }
            }// zstack
            .modifier(EdgeSwipe())
        }//navigationstack
        .onDisappear {
            if let currentUser = AuthService.shared.currentUser {
                viewModel.user = currentUser
            }
        }
    }//body
    
    private func editBackgroundImage() -> some View {
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
    }
    
    private func editUserName() -> some View {
        VStack (spacing:10){
            VStack(spacing: 5) {
                Text("ユーザー名（20文字以内）")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.gray)
                
                if !viewModel.isUsernameValid {
                    Text("適切なユーザー名を入力してください")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.orange)
                        .padding(.leading, 5)
                }
            }

            VStack {
                TextField("", text: $viewModel.user.username)
                    .padding(.leading, 5)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .autocorrectionDisabled(true)

                Divider()
            }//vstack
        }//vstack
        .font(.subheadline)
        .padding(5)
        .focused($focusedField, equals: .title)
    }
    
    private func editBio() -> some View {
        VStack {
            HStack {
                Text("自己紹介（100文字以内）")
                    .font(.footnote)
                    .foregroundColor(.gray)

                // 文字制限を超えている場合
                if !viewModel.isNotOverCharacterLimit {
                    Text("自己紹介は100字以内で入力してください")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                TextField("", text: Binding(
                    get: { viewModel.user.bio ?? "" },
                    set: { viewModel.user.bio = $0 }
                ), axis: .vertical)
                .lineLimit(5, reservesSpace: true)
                .padding(.horizontal, 5)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .autocorrectionDisabled(true)
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
                
                Divider()
            }
        }
        .font(.subheadline)
        .padding(5)
        .focused($focusedField, equals: .title)
    }
    
    private func editInterestTags() -> some View {
        EditInterestView(texts: $texts)
            .focused($focusedField, equals: .title)
    }
}//view

struct EditInterestView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @State private var isShowAlert: Bool = false
    @Binding var texts: [String]

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

                if viewModel.user.interestTags.isEmpty{
                    Text("興味タグがありません")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                        .padding(.leading, 15)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(viewModel.user.interestTags, id: \.self) { tag in
                                HStack(spacing: 0) {
                                    Image(systemName: "number")

                                    Text(tag)
                                        .fontWeight(.bold)
                                }
                                .font(.footnote)
                                .foregroundStyle(.blue)
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        viewModel.deleteTag(tag: tag)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.footnote)
                                            .foregroundStyle(.black)
                                            .offset(x: 10, y: -8)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 15)
                }
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        }
    }
}

#Preview {
    EditInterestView(texts: .constant([""]))
}

