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
    let availableOpacity: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(backgroundColor(for: text).opacity(availableOpacity ? 0.8 : 1.0))
            .frame(width: 80, height: 25)
            .overlay {
                Text(text)
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .fontWeight(.bold)
            }
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

struct Attributes: View {
    let attributes: [String]
    let availableOpacity: Bool
        
    var body: some View {
        HStack(spacing: 5) {
            ForEach(attributes, id: \.self) { attribute in
                AttributeView(text: attribute, availableOpacity: availableOpacity)
            }
        }
    }
}

// プレビュー
//#Preview {
//    AttributeView(text: "FullStack")
//    AttributeView(text: "FrontEnd")
//    AttributeView(text: "BackEnd")
//    AttributeView(text: "Native")
//    AttributeView(text: "Game")
//    AttributeView(text: "SRE")
//    AttributeView(text: "Security")
//    AttributeView(text: "AI")
//    AttributeView(text: "Hardware")
//    AttributeView(text: "3DModeling")
//}
