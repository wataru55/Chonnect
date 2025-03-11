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
    private var tags: Binding<[String]>?
    private var constantTags: [String]?
    let isShowDeleteButton: Bool
    let textFont: TextFont
    
    @State private var isShowAlert: Bool = false
    @State private var tagToDelete: String?
    
    // Bindingを受け取る初期化子
    init(interestTags: Binding<[String]>, isShowDeleteButton: Bool, textFont: TextFont) {
        self.tags = interestTags
        self.constantTags = nil
        self.isShowDeleteButton = isShowDeleteButton
        self.textFont = textFont
    }
    
    // 定数を受け取る初期化子
    init(interestTags: [String], isShowDeleteButton: Bool, textFont: TextFont) {
        self.tags = nil
        self.constantTags = interestTags
        self.isShowDeleteButton = isShowDeleteButton
        self.textFont = textFont
    }

    var body: some View {
        // Bindingがあればそちら、なければ定数を使用
        let interestTags = tags?.wrappedValue ?? constantTags ?? []
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(interestTags, id: \.self) { tag in
                    HStack(spacing: 0) {
                        Image(systemName: "number")

                        Text(tag)
                            .fontWeight(.bold)
                    }
                    .font(textFont.font)
                    .foregroundStyle(.blue)
                    .overlay(alignment: .topTrailing) {
                        // 編集可能なのはBindingの場合だけにする
                        if isShowDeleteButton, let tags = tags {
                            Button {
                                if let index = tags.wrappedValue.firstIndex(of: tag) {
                                    tags.wrappedValue.remove(at: index)
                                }
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
                if let tags = tags {
                    tags.wrappedValue.removeAll { $0 == tag }
                }
                Task {
                    tagToDelete = nil // 削除後にリセット
                }
            }
        } message: { tag in
            Text("このタグを削除しますか？")
        }
    }
}

//#Preview {
//    InterestTagView(interestTag: ["SwiftUI", "UIKit"], isShowDeleteButton: false, textFont: .footnote)
//}
