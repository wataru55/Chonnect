//
//  TopTabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/02.
//

import SwiftUI

struct TopTabView: View {
    @StateObject var viewModel = BLEHistoryViewModel()
    @State private var selectedTab = 0
    @State private var isShowpopup = false
    
    let currentUser: User

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack(alignment: .trailing){
                    CustomTabBarButtonView(selected: $selectedTab, title: "すれちがい履歴", tag: 0)
                    if viewModel.isShowMarker {
                        exclamationmark()
                    }
                }
                CustomTabBarButtonView(selected: $selectedTab, title: "リアルタイム", tag: 1)
            }
            .padding()

            TabView(selection: $selectedTab) {
                BLEHistoryView(viewModel: viewModel, currentUser: currentUser)
                    .tag(0)
                
                BLERealtimeView(currentUser: currentUser)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // インジケータを非表示
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func exclamationmark() -> some View {
        Button {
            print("click")
            isShowpopup = true
        } label: {
            Image(systemName: "exclamationmark.circle.fill")
                .frame(width: 8, height: 8)
                .foregroundStyle(.mint)
                .offset(x: -8)
                
        }
        .contentShape(Rectangle())
        .popover(isPresented: $isShowpopup) {
            Text("すれちがい履歴に更新データがあります")
                .font(.footnote)
                .fontWeight(.bold)
                .presentationCompactAdaptation(PresentationAdaptation.popover)
        }
    }
}

#Preview {
    TopTabView(currentUser: User.MOCK_USERS[0])
}
