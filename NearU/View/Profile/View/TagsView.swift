//
//  TagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/15.
//

import SwiftUI

struct TagsView: View {
    var tags: [String]
    //let userId: String

    var body: some View {
        VStack {
            if tags.isEmpty {
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .semibold, design: .default))
                                .foregroundColor(.black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                                )
                        }
                    }
                    
                }
                .frame(height: 25) // タグが収まる高さに設定
            }
            
        }
    }
}
