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
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(15)
                        }
                    }
                    
                }
                .frame(height: 50) // タグが収まる高さに設定
                .padding(.leading)
                .padding(.trailing)
            }
            
        }
    }
}
