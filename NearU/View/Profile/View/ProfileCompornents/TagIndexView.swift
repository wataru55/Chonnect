//
//  TagIndexView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/23.
//

import SwiftUI

struct TagIndexView: View {
    @ObservedObject var viewModel: EditSkillTagsViewModel
    @State private var selectedTab: Int = 0
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack {

                TabView(selection: $selectedTab) {
                    WordCloudView(viewModel: viewModel)
                        .tag(0)

                    WordCloudView(viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .overlay(alignment: selectedTab == 0 ? .trailing : .leading ) {
                Button {
                    selectedTab = selectedTab == 0 ? 1 : 0
                } label: {
                    Image(systemName: selectedTab == 0 ? "chevron.right" : "chevron.left")
                        .font(.title3)
                        .padding(10)
                        .foregroundStyle(.gray)
                        .background(
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        )
                }
                .padding(4)

            }
        }
    }
}

#Preview {
    TagIndexView(viewModel: EditSkillTagsViewModel())
}
