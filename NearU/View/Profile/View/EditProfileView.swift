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
                        try await viewModel.updateUserTags()
                        try await AuthService.shared.loadUserData()
                        try await viewModel.loadUserTags()

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
                    EditTagsView(selectedTags: $viewModel.selectedTags, userId: viewModel.user.id)
                    EditProfileRowView(title: "userName", placeholder: "Enter your username", text: $viewModel.username)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "fullName", placeholder: "Enter your fullname", text: $viewModel.fullname)
                        .focused($focusedField, equals: .title)
                    EditProfileRowView(title: "bio", placeholder: "Enter your bio", text: $viewModel.bio)
                        .focused($focusedField, equals: .title)
                }
                .padding(.top, 30)
                
                ScrollView(.horizontal, showsIndicators: false) {
                   HStack {
                       if user.snsLinks.isEmpty {
                           Text("自分のSNSのリンクを登録しましょう")
                               .foregroundColor(.orange)
                               .padding()
                       } else {
                           ForEach(Array(user.snsLinks.keys), id: \.self) { key in
                               if let url = user.snsLinks[key] {
                                   SNSLinkButtonView(selectedSNS: key, sns_url: url,  backgroundColor: .white)
                               }
                           }
                       }
                   } // HStack
                } // ScrollView
                .padding(.leading)
                .padding(.bottom, 10)
                
                VStack(){
                    if abstractLinksViewModel.abstractLinks.isEmpty {
                        Text("リンクがありません")
                            .foregroundColor(.orange)
                            .padding()
                    } else {
                        ForEach(Array(abstractLinksViewModel.abstractLinks.keys), id: \.self) { key in
                            if let url = abstractLinksViewModel.abstractLinks[key] {
                                SiteLinkButtonView(abstract_title: key, abstract_url: url)
                            }
                        }
                    }
                }
                
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
                    AddLinkView(isPresented: $isAddingNewLink, user: viewModel.user)
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

//#Preview {
//    EditProfileView()
//}
