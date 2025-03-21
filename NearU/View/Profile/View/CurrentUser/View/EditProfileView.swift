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
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @FocusState private var focusedField: Field?

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
                                
                                await viewModel.updateUserData(addTags: viewModel.user.interestTags)

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
            Text("自己紹介（100文字以内）")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !viewModel.isNotOverCharacterLimit {
                Text("自己紹介は100字以内で入力してください")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }

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
        VStack(spacing: 5) {
            Text("興味タグ（上限10, 1つ20文字以内）")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)

            Button {
                if viewModel.user.interestTags.count < 10 {
                    viewModel.user.interestTags.insert("", at: 0)
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("入力欄を追加")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(viewModel.user.interestTags.count < 10 ? Color.mint : Color.gray)
                .padding(.vertical, 5)
            }
            
            if !viewModel.isInterestedTagValid {
                Text("20文字以上の興味タグが含まれています")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }
            
            ForEach($viewModel.user.interestTags.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    TextField("興味・関心", text: $viewModel.user.interestTags[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.subheadline)
                    
                    Button {
                        viewModel.deleteTag(tag: viewModel.user.interestTags[index])
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.black)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal, 10)
            }

        }
        .padding(.horizontal, 8)
        .focused($focusedField, equals: .title)
    }
}//view

#Preview {
    EditProfileView()
}

