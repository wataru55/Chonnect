//
//  EditTagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/16.
//
import SwiftUI

struct EditTagsView: View {
    @State private var tags: [String] = ["Python", "Java", "Ruby"] // 固定のタグ
    @State private var selectedTags: [String] = [] // 選択されたタグを保持する配列
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
                                .background(self.selectedTags.contains(tag) ? Color.blue : Color(.systemGroupedBackground)) // 選択された場合は青色
                                .foregroundColor(self.selectedTags.contains(tag) ? .white : .black) // 選択された場合はテキストを白色
                                .cornerRadius(15)
                                .onTapGesture {
                                    toggleTagSelection(tag: tag)
                                }
                        }
                    }
                    .padding(5)
                }
                .frame(height: 50) // タグが収まる高さに設定
            }
        }
        .onAppear {
            Task {
                do {
                    // Firestoreから既に選択されたタグを取得
                    self.selectedTags = try await UserService.fetchUserTags(withUid: userId)
                } catch {
                    print("Failed to fetch tags: \(error)")
                }
            }
        }
    }
    
    // タグの選択をトグルし、Firestoreに保存する関数
    private func toggleTagSelection(tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index) // 選択済みの場合は削除
        } else {
            selectedTags.append(tag) // 未選択の場合は追加
        }
        
        // Firestoreに選択したタグを保存
        Task {
            do {
                try await UserService.saveUserTags(userId: userId, selectedTags: selectedTags)
            } catch {
                print("Failed to save tags: \(error)")
            }
        }
    }
}
