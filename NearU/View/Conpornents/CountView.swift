//
//  FollowCountView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct CountView: View {
    let count: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 3) {
            Text("\(count)")
                .fontWeight(.bold)

            Text(text)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    CountView(count: 500, text: "フォロー")
}
