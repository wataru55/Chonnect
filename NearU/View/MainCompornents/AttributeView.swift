//
//  AttributeView.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/28.
//

import SwiftUI

enum AttributeOption {
    case profile
    case edit
    case row
    
    var font: Font {
        switch self {
        case .profile, .edit:
            return .footnote
        case .row:
            return .caption
        }
    }
    
    var availableOpacity: Bool {
        switch self {
        case .profile:
            return true
        case .edit, .row:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .profile, .edit:
            return 25
            
        case .row:
            return 20
        }
    }
    
}

struct AttributeView: View {
    let text: String
    let option: AttributeOption

    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(backgroundColor(for: text).opacity(option.availableOpacity ? 0.8 : 1.0))
            .frame(width: 80, height: option.height)
            .overlay {
                Text(text)
                    .foregroundStyle(.white)
                    .font(option.font)
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
    let option: AttributeOption
        
    var body: some View {
        HStack(spacing: 5) {
            ForEach(attributes, id: \.self) { attribute in
                AttributeView(text: attribute, option: option)
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
