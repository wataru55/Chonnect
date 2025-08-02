//
//  EditProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State var path = NavigationPath()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    editBackgroundImage()
                    
                    editUserName()
                    
                    Divider()
                    
                    editBio()
                    
                    Divider()
                    
                    editAttributes()
                    
                    Divider()
                    
                    editInterestTags()
                }//vstack
                .padding(.top, 5)
            } //scrollview
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
            }
        }// vstack
        .background(
            backgroundColor.ignoresSafeArea()
        )
        .overlay {
            ViewStateOverlayView(state: $viewModel.state)
        }
        .modifier(EdgeSwipe())
        .navigationBarBackButtonHidden()
    }//body
    
    // MARK: - Private Functions
    
    private func editBackgroundImage() -> some View {
        NavigationLink(value: CurrentUserProfileDestination.profileImage) {
            VStack {
                BackgroundImageView(user: viewModel.user, height: 250, isGradient: false)
                
                Text("プロフィール画像を変更")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mint)
                    .padding(.bottom, 10)
            }//vstack
        }
    }
    
    private func editUserName() -> some View {
        NavigationLink(value: CurrentUserProfileDestination.userName) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    captionText(text: "ユーザーネーム")
            
                    Text(viewModel.user.username)
                        .padding(.horizontal, 5)
                }
                
                Spacer()
                
                chevron()
            }
            .font(.subheadline)
            .padding(5)
            .padding(.vertical, 5)
        }
    }
    
    private func editBio() -> some View {
        NavigationLink(value: CurrentUserProfileDestination.bio) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    captionText(text: "自己紹介")
                    
                    Text(viewModel.user.bio ?? "")
                        .padding(.horizontal, 5)
                        .multilineTextAlignment(TextAlignment.leading)
                        .lineLimit(5, reservesSpace: true)
                }
                
                Spacer()
                
                chevron()
            }
            .font(.subheadline)
            .padding(5)
            .padding(.vertical, 5)
        }
    }
    
    private func editAttributes() -> some View {
        NavigationLink(value: CurrentUserProfileDestination.attribute) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    captionText(text: "属性")
                    
                    Attributes(attributes: viewModel.user.attributes, availableOpacity: false)
                        .padding(.horizontal, 5)
                }
                
                Spacer()
                
                chevron()
            }
            .font(.subheadline)
            .padding(5)
            .padding(.vertical, 5)
        }
    }
    
    private func editInterestTags() -> some View {
        NavigationLink(value: CurrentUserProfileDestination.interestTags) {
            HStack {
                VStack(spacing: 5) {
                    captionText(text: "興味タグ")
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), alignment: .leading, spacing: 10) {
                        ForEach(viewModel.user.interestTags, id: \.self) { tag in
                            HStack(spacing: 0) {
                                Image(systemName: "number")

                                Text(tag)
                                    .fontWeight(.bold)
                            }
                            .font(.footnote)
                            .foregroundStyle(.blue)
                        }
                    } // LazyVGrid
                    .padding(.top, 5)
                    .padding(.horizontal, 5)
                }
                
                Spacer()
                
                chevron()
            }
            .padding(5)
            .padding(.vertical, 5)
        }
    }
}//view

private func chevron() -> some View {
    Image(systemName: "chevron.forward")
        .foregroundStyle(.gray)
        .padding(.trailing, 5)
}

private func captionText(text: String) -> some View {
    Text(text)
        .font(.footnote)
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
}

//#Preview {
//    EditProfileView()
//}

