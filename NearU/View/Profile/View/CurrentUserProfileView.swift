//
//  CurrentUserProfileView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/21.
//

import SwiftUI

struct CurrentUserProfileView: View {
    //MARK: - property
    let user: User
    let GridItems : [GridItem] = Array(repeating: .init(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ProfileHeaderView(user: user)
                    Divider() //境界線
                    //post grid view
                    LazyVGrid(columns: GridItems, spacing: 2, content: {
                        ForEach(0...15, id: \.self) { index in
                            Image("avengers")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipped()

                        }
                    })//lazyvgrid
                }//Vstack
            }//scrollView
            .navigationTitle(user.username)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        AuthService.shared.signout()
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.black)
                    })
                }
            }
        }
    }
}

#Preview {
    CurrentUserProfileView(user: User.MOCK_USERS[2])
}
