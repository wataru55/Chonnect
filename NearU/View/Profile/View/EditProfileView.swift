//
//  EditProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel : EditProfileViewModel

    init(user: User) {
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
            VStack {
                PhotosPicker(selection: $viewModel.selectedImage) {
                    VStack {
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.gray)
                                .clipShape(Circle())
                        } else {
                            CircleImageView(user: viewModel.user, size: .large)
                        }

                        Text("Edit profile picture")
                            .font(.footnote)
                            .fontWeight(.semibold)

                        Divider()
                    }//vstack
                }
            }//vstack
            //edit profile info
            VStack {
                EditProfileRowView(title: "Name", placeholder: "Enter your name", text: $viewModel.fullname)
                EditProfileRowView(title: "bio", placeholder: "Enter your bio", text: $viewModel.bio)
            }

            Spacer()
        }//vstack
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
