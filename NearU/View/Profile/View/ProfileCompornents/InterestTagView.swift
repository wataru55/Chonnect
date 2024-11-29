//
//  InterestTagView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/25.
//

import SwiftUI

struct InterestTagView: View {
    @State private var tagToDelete: InterestTag?
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
                    .foregroundStyle(.black)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)
                    )
                    .overlay(alignment: .topTrailing) {
                        if isShowDeleteButton {
                            Button {
                                tagToDelete = tag // 削除対象のタグを設定
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .offset(x: 8, y: -5)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 40)
        .alert(item: $tagToDelete) { tag in
            Alert(
                title: Text("確認"),
                message: Text("このタグを削除しますか？"),
                primaryButton: .destructive(Text("削除")) {
                    Task {
                        await UserService.deleteInterestTags(id: tag.id.uuidString)
                        await viewModel.loadInterestTags()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    InterestTagView(interestTag: [InterestTag(id: UUID(), text: "SwiftUI"), InterestTag(id: UUID(), text: "UIKit")], isShowDeleteButton: true)
}
