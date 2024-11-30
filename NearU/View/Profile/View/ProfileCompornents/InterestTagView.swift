//
//  InterestTagView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/25.
//

import SwiftUI

struct InterestTagView: View {
    @State private var isShowAlert: Bool = false
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    let interestTag: [InterestTag]
    let isShowDeleteButton: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(interestTag, id: \.self) { tag in
                    HStack(spacing: 0) {
                        Image(systemName: "number")

                        Text(tag.text)
                            .fontWeight(.bold)
                    }
                    .font(.caption2)
                    .foregroundStyle(.blue)
                    .overlay(alignment: .topTrailing) {
                        if isShowDeleteButton {
                            Button {
                                isShowAlert.toggle()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .offset(x: 8, y: -5)
                            }
                            .alert("確認", isPresented: $isShowAlert) {
                                Button("削除", role: .destructive) {
                                    Task {
                                        await UserService.deleteInterestTags(id: tag.id.uuidString)
                                        await viewModel.loadInterestTags()
                                    }
                                }
                            } message: {
                                Text("このタグを削除しますか？")
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 20)
    }
}

#Preview {
    InterestTagView(interestTag: [InterestTag(id: UUID(), text: "SwiftUI"), InterestTag(id: UUID(), text: "UIKit")], isShowDeleteButton: true)
}
