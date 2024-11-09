//
//  EditTagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/16.
//
import SwiftUI

struct EditFrameworkTagsView: View {
    @State private var FrameworkTags: [String] = ["React","Next.js","Vue","Nuxt.js","Angular","Node.js","Django","Flask","Laravel","CakePHP","Flutter","Rails","Remix","Tailwind CSS","Spring"]
    @Binding var selectedFrameworkTags: [String]
    let userId: String

    var body: some View {
        VStack {
            if FrameworkTags.isEmpty {
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(FrameworkTags, id: \.self) { tag in
                            Text(tag)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(self.selectedFrameworkTags.contains(tag) ? Color.blue : Color(.systemGroupedBackground))
                                .foregroundColor(self.selectedFrameworkTags.contains(tag) ? .white : .black)
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
        .padding(.bottom, 15)
    }

    // タグの選択をトグルし、Firestoreに保存する関数
    private func toggleTagSelection(tag: String) {
        if let index = selectedFrameworkTags.firstIndex(of: tag) {
            selectedFrameworkTags.remove(at: index)
        } else {
            selectedFrameworkTags.append(tag)
        }
    }
}
