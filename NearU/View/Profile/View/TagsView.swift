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
                Text("No tags")
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(15)
                        }
                    }
                    .padding(5)
                }
                .frame(height: 50) // タグが収まる高さに設定
            }
        }
//        .onAppear {
//            Task {
//                do {
//                    self.tags = try await UserService.fetchUserTags(withUid: userId)
//                } catch {
//                    print("Failed to fetch tags: \(error)")
//                }
//            }
//        }
    }
}
