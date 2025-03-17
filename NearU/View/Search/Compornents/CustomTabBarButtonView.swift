//
//  CustomTabBarButtonView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import SwiftUI

struct CustomTabBarButtonView: View {
    @Binding var selected: Int
    private var title: String
    var tag: Int

    init(selected: Binding<Int>, title: String, tag: Int) {
        self._selected = selected
        self.title = title
        self.tag = tag
    }

    var body: some View {
        Button {
            selected = tag

        } label: {
            VStack(spacing: 0) {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(10)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color(.systemMint))
                    .opacity(selected != tag ? 0.0 : 1.0)
            }
        }
    }
}

#Preview {
    CustomTabBarButtonView(selected: .constant(0), title: "すれちがい履歴", tag: 0)
}
