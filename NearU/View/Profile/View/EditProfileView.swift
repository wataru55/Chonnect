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
    
    //let user: User
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
                            
                            Text("Edit background picture")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Divider()
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
                        .opacity(0.7)
                        .foregroundColor(Color.gray)
                    EditLanguageTagsView(selectedLanguageTags: $viewModel.selectedLanguageTags, userId: viewModel.user.id)
                    Text("フレームワーク")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                        .opacity(0.7)
                        .foregroundColor(Color.gray)
                    EditFrameworkTagsView(selectedFrameworkTags: $viewModel.selectedFrameworkTags, userId: viewModel.user.id)
                    EditProfileRowView(title: "userName", placeholder: "Enter your username", text: $viewModel.username)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "fullName", placeholder: "Enter your fullname", text: $viewModel.fullname)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "bio", placeholder: "Enter your bio", text: $viewModel.bio)
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
        HStack {
            Text(title)
                .padding(.leading, 8)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            VStack {
                TextField(placeholder, text: $text)
                
                Divider()
            }//vstack
        }//hstack
        .font(.subheadline)
        .frame(height: 36)
    }//body
}//view

//#Preview {
//    EditProfileView()
//}
