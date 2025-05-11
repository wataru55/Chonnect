//
//  NothingDataView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/15.
//

import SwiftUI

struct NothingDataView: View {
    let text: String
    let explanation: String
    let isSystemImage: Bool
    let isAbleToReload: Bool
    
    @State private var textWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 50) {
            if isAbleToReload {
                HStack {
                    Image(systemName: "arrowshape.down.circle")
                    Text("下にスクロールして再読み込み")
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Group {
                if isSystemImage {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                } else {
                    Image("sleep")
                        .resizable()
                        .frame(width: 150, height: 75)
                }
            }
            
            VStack(spacing: 20) {
                Text(text)
                    .font(.title3)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: TextWidthPreferenceKey.self, value: proxy.size.width)
                        }
                    )
                
                Text(explanation)
                    .font(.subheadline)
                    .frame(width: textWidth)
            
            }
            .onPreferenceChange(TextWidthPreferenceKey.self) { newWidth in
                textWidth = newWidth
            }
            .fontWeight(.bold)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.gray)
    }
}

struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NothingDataView(text: "すれちがったユーザーがいません",
                    explanation: """
                                ここでは、過去にすれちがったユーザーの一覧が表示されます。
                                """,
                    isSystemImage: false,
                    isAbleToReload: true)
}
