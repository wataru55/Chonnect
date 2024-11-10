//
//  TagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/15.
//

import SwiftUI

// タグとアイコン画像の名前の対応関係を定義
private let iconMapping: [String: String] = [
    // 言語
    "JavaScript": "JavaScript",
    "Python": "Python",
    "Java": "Java",
    "Ruby": "Ruby",
    "Swift": "Swift",
    "PHP": "PHP",
    "TypeScript": "TypeScript",
    "Go": "Go",
    "C": "C",
    "C++": "C-plus",
    "Kotlin": "Kotlin",
    "C#": "C-sharp",
    "HTML": "HTML",
    "CSS": "CSS",
    "Rust": "Rust",
    "Dart": "Dart",
    "Elixir": "Elixir",
    // フレームワーク
    "React": "React",
    "Next.js": "Next-js",
    "Vue": "Vue",
    "Nuxt.js": "Nuxt-js",
    "Angular": "Angular",
    "Node.js": "Node-js",
    "Django": "Django",
    "Flask": "Flask",
    "Laravel": "Laravel",
    "CakePHP": "CakePHP",
    "Flutter": "Flutter",
    "Rails": "Rails",
    "Remix": "Remix",
    "Tailwind CSS": "Tailwind-CSS",
    "Spring": "Spring"
]


struct TagsView: View {
    var tags: [String]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            // アイコンを表示
                            if let iconName = iconMapping[tag] {
                                Image(iconName)
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                            Text(tag)
                                .font(.system(size: 10, weight: .semibold, design: .default))
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

