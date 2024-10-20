//
//  EditTagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/16.
//
import SwiftUI

struct EditTagsView: View {
    @State private var tags: [String] = ["Python", "Java", "Ruby"] // 固定のタグ
    @Binding var selectedTags: [String] // バインディングでタグを親ビューと共有
    let userId: String

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
                                .background(self.selectedTags.contains(tag) ? Color.blue : Color(.systemGroupedBackground)) // 選択されていれば青背景
                                .foregroundColor(self.selectedTags.contains(tag) ? .white : .black) // 選択されていれば白テキスト
                                .cornerRadius(15)
                                .onTapGesture {
                                    toggleTagSelection(tag: tag)
                                }
                        }
                    }
                    .padding(5)
                }
                .frame(height: 50)
            }
        }
//        .onAppear {
//            Task {
//                do {
//                    // Firestoreから既に選択されたタグを取得
//                    self.selectedTags = try await UserService.fetchUserTags(withUid: userId)
//                } catch {
//                    print("Failed to fetch tags: \(error)")
//                }
//            }
//        }
    }

    // タグの選択をトグルし、Firestoreに保存する関数
    private func toggleTagSelection(tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index) // 選択済みタグを解除
        } else {
            selectedTags.append(tag) // タグを選択
        }
    }
}
