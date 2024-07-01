//
//  ProfileHeaderView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: User
    @State private var showEditProfile = false

    var body: some View {
        VStack (spacing: 15){
            // image and stats
            HStack (spacing: 35){
                CircleImageView(user: user, size: .large)
            }

            //name and info
            VStack (alignment: .leading, content: {
                if let fullname = user.fullname {
                    Text(fullname)
                        .font(.footnote)
                        .fontWeight(.bold)
                }

                if let bio = user.bio {
                    Text(bio)
                        .font(.footnote)
                }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            //action button
            Button(action: {
                if user.isCurrentUser {
                    showEditProfile.toggle()
                } else {
                    print("Pressed Edit Profile")
                }
            }, label: {
                Text(user.isCurrentUser ? "Edit Profile" : "Follow")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 360, height: 32)
                    .background(user.isCurrentUser ? .white : Color(.systemMint)) 
                    .cornerRadius(6)
                    .foregroundStyle(user.isCurrentUser ? .black : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(user.isCurrentUser ? .gray : .clear, lineWidth: 1)
                    )
            })
        }//vstack
        .fullScreenCover(isPresented: $showEditProfile, content: {
            EditProfileView(user: user)
        })
    }//body
}//view

#Preview {
    ProfileHeaderView(user: User.MOCK_USERS[0])
}
