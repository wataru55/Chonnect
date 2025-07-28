//
//  AttributeView.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/28.
//

import SwiftUI

import SwiftUI

struct AttributeView: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(.white)
            .font(.footnote)
            .fontWeight(.bold)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor(for: text))
                    .frame(width: 80)
            )
    }

    // タグの内容に応じた色を返す関数
    private func backgroundColor(for text: String) -> Color {
        switch text {
        case "FullStack":
            return .green
        case "FrontEnd":
            return .mint
        case "BackEnd":
            return .cyan
        case "Native":
            return .indigo
        case "Game":
            return .red
        case "SRE":
            return .blue
        case "Security":
            return .gray
        case "AI":
            return .black
        case "Hardware":
            return .brown
        case "3DModeling":
            return .orange
        default:
            return .gray
        }
    }
}

// プレビュー
#Preview {
    AttributeView(text: "FullStack")
    AttributeView(text: "FrontEnd")
    AttributeView(text: "BackEnd")
    AttributeView(text: "Native")
    AttributeView(text: "Game")
    AttributeView(text: "SRE")
    AttributeView(text: "Security")
    AttributeView(text: "AI")
    AttributeView(text: "Hardware")
    AttributeView(text: "3DModeling")
}
