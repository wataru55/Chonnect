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
    
    // 技術名とアイコン画像名の対応を定義
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
        "Spring": "Spring",
        // データベース
        "MySQL": "MySQL",
        "PostgreSQL": "PostgreSQL",
        "MongoDB": "MongoDB",
        "Redis": "Redis",
        "MariaDB": "MariaDB",
        "DynamoDB": "DynamoDB",
        // その他
        "AWS": "AWS",
        "GCP": "GCP",
        "Azure": "Azure",
        "Cloudflare": "Cloudflare",
        "Vercel": "Vercel",
        "Firebase": "Firebase",
        "Supabase": "Supabase",
        "Terraform": "Terraform",
        "Unity": "Unity",
        "Blender": "Blender",
        "Docker": "Docker",
        "ROS": "ROS"
    ]
    
    var body: some View {
        HStack {
            HStack(alignment: .bottom, spacing: -5) {
                ForEach(Array(tags.prefix(3).enumerated()), id: \.offset) { index, item in
                    if let iconName = iconMapping[item.name] {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                            .padding(10)
                            .clipShape(Circle())
                            .zIndex(Double(Ranking(rawValue: index)?.index() ?? 0))
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
                                    .font(.system(size: 8))
                                    .foregroundStyle(Ranking(rawValue: index)?.color() ?? .clear)
                                    .offset(y: -8)
                            }
                    } else {
                        // アイコンが見つからない場合のデフォルト
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                            .padding(10)
                            .clipShape(Circle())
                            .foregroundStyle(.gray)
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
            .frame(height: 35)
        }
    }
}

#Preview {
    Top3TabView(tags: [
        WordElement(id: UUID(), name: "Swift", skill: "3"),
        WordElement(id: UUID(), name: "Python", skill: "3"),
        WordElement(id: UUID(), name: "AWS", skill: "2")
    ])
}
