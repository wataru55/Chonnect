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
    @StateObject var viewModel : EditProfileViewModel
    
    let user: User
    @FocusState private var focusedField: Field?
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
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
                        try await UserService.saveUserTags(userId: user.id, selectedTags: viewModel.selectedTags) 
                        try await AuthService.shared.loadUserData()
                        
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
                VStack {
                    EditTagsView(selectedTags: $viewModel.selectedTags, userId: user.id)
                    EditProfileRowView(title: "userName", placeholder: "Enter your username", text: $viewModel.username)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "fullName", placeholder: "Enter your fullname", text: $viewModel.fullname)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "bio", placeholder: "Enter your bio", text: $viewModel.bio)
                        .focused($focusedField, equals: .title)
                }
                .padding(.top, 30)
                
                // add link button
                Button(action: {
                    isAddingNewLink.toggle()
                }, label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    Text("Add Link")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                })
                .foregroundColor(.white)
                .frame(width: 360, height: 35)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing)
                        .clipShape(Capsule())
                )
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0.0, y: 4.0)
                .sheet(isPresented: $isAddingNewLink) {
                    AddLinkView(isPresented: $isAddingNewLink, user: user)
                }
                .padding(.bottom, 20)
                
                Spacer()
                
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

#Preview {
    EditProfileView(user: User.MOCK_USERS[0])
}
