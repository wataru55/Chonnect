//
//  TopTabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct TopTabView: View {
    let currentUser: User

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                CustomTabBarButtonView(selected: $selectedTab, title: "すれちがい履歴", tag: 0)
                CustomTabBarButtonView(selected: $selectedTab, title: "リアルタイム", tag: 1)
            }
            .padding()


            if selectedTab == 0 {
                BLEHistoryView(currentUser: currentUser).tag(0)
            } else {
                ConnectedSearchView(currentUser: currentUser).tag(1)
            }
        }
        .ignoresSafeArea(edges: .bottom)

    }
}

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
    TopTabView(currentUser: User.MOCK_USERS[0])
}
