//
//  Top3TabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/24.
//

import SwiftUI

enum Ranking: Int {
    case first = 0
    case second = 1
    case third = 2

    func color() -> Color {
        switch self {
        case .first:
            return .yellow
        case .second:
            return .gray
        case .third:
            return .brown
        }
    }

    func index() -> Int {
        switch self {
        case .first:
            return 3
        case .second:
            return 2
        case .third:
            return 1
        }
    }
}

struct Top3TabView: View {
    let tags: [WordElement]

    var body: some View {
        HStack {
            HStack(alignment: .bottom, spacing: -5) {
                ForEach(Array(tags.prefix(3).enumerated()), id: \.offset) { index, item in
                    Image("\(item.name)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15) // 画像の高さを20に設定
                        .padding(10) // 上下に5のパディング
                        .clipShape(Circle())
                        .zIndex(Double(Ranking(rawValue: index)?.index() ?? 0)) // 前面に表示
                        .background(
                            Circle()
                                .foregroundStyle(.black.opacity(0.3))
                        )
                        .overlay {
                            Circle()
                            .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                        }
                        .overlay(alignment: .top) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8)) // クラウンアイコンのサイズを小さく
                                .foregroundStyle(Ranking(rawValue: index)?.color() ?? .clear)
                                .offset(y: -8) // アイコンの位置を調整
                        }
                }

                if tags.count > 3 {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .clipShape(Circle())
                        .background(
                            Circle()
                                .foregroundStyle(.black.opacity(0.3))
                        )
                        .overlay {
                            Circle()
                                .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                        }
                }
            }
            .frame(height: 35) // HStack の高さを30に設定
        }
    }
}

#Preview {
    Top3TabView(tags: [WordElement(id: UUID(), name: "Swift", skill: "3", interest: "1")])
}
