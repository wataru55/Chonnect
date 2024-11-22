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
                BLERealtimeView(currentUser: currentUser).tag(1)
            }
        }
        .ignoresSafeArea(edges: .bottom)

    }
}

#Preview {
    TopTabView(currentUser: User.MOCK_USERS[0])
}
