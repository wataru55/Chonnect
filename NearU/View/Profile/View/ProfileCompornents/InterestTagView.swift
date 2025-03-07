//
//  InterestTagView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/25.
//

import SwiftUI

enum TextFont {
    case caption
    case footnote

    var font: Font {
        switch self {
        case .caption:
            return .caption2
        case .footnote:
            return .footnote
        }
    }
}

struct InterestTagView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @State private var isShowAlert: Bool = false
    @State private var tagToDelete: String?
    @State var interestTag: [String]
    let isShowDeleteButton: Bool
    let textFont: TextFont

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(interestTag, id: \.self) { tag in
                    HStack(spacing: 0) {
                        Image(systemName: "number")

                        Text(tag)
                            .fontWeight(.bold)
                    }
                    .font(textFont.font)
                    .foregroundStyle(.blue)
                    .overlay(alignment: .topTrailing) {
                        if isShowDeleteButton {
                            Button {
                                tagToDelete = tag
                                isShowAlert = true
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .offset(x: 10, y: -8)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: isShowDeleteButton ? 40 : 20)
        .alert("確認", isPresented: $isShowAlert, presenting: tagToDelete) { tag in
            Button("削除", role: .destructive) {
                Task {
                    tagToDelete = nil // 削除後にリセット
                }
            }
        } message: { tag in
            Text("このタグを削除しますか？")
        }
    }
}

#Preview {
    InterestTagView(interestTag: ["SwiftUI", "UIKit"], isShowDeleteButton: false, textFont: .footnote)
}
