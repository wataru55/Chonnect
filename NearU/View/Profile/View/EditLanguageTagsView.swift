//
//  EditTagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/16.
//
import SwiftUI

struct EditLanguageTagsView: View {
    @State private var LanguageTags: [String] = ["JavaScript","Python", "Java", "Ruby","Swift","PHP","TypeScript","Go","C","C++","Kotlin","C#","HTML","CSS","Rust","Dart","Elixir"]
    @Binding var selectedLanguageTags: [String]
    let userId: String

    var body: some View {
        VStack {
            if LanguageTags.isEmpty {
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(LanguageTags, id: \.self) { tag in
                            Text(tag)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(self.selectedLanguageTags.contains(tag) ? Color.blue : Color(.systemGroupedBackground))
                                .foregroundColor(self.selectedLanguageTags.contains(tag) ? .white : .black)
                                .cornerRadius(15)
                                .onTapGesture {
                                    toggleTagSelection(tag: tag)
                                }
                        }
                    }
                    .padding(5)
                }
                .frame(height: 35)
            }
        }
    }

    // タグの選択をトグルし、Firestoreに保存する関数
    private func toggleTagSelection(tag: String) {
        if let index = selectedLanguageTags.firstIndex(of: tag) {
            selectedLanguageTags.remove(at: index)
        } else {
            selectedLanguageTags.append(tag)
        }
    }
}
