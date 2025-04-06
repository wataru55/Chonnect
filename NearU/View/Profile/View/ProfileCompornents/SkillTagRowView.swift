//
//  SkillTagRowView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/23.
//

import SwiftUI

struct SkillTagRowView: View {
    @ObservedObject var viewModel: EditSkillTagsViewModel
    @State private var isShowTechTags: Bool = false
    @State private var isShowAlert: Bool = false
    @Binding var language: WordElement
    let skillLevels: [String]
    let isShowDeleteButton: Bool

    var body: some View {
        HStack(spacing: 0) {
            Button {
                isShowTechTags.toggle()
            } label: {
                HStack {
                    Text(language.name.isEmpty ? "一覧" : language.name)
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Image(systemName: "text.justify")
                        .foregroundStyle(.mint)
                }
                .font(.footnote)
            }
            .frame(width: 150, height: 20)

            Spacer()

            Text("技術レベル")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            Picker("レベル", selection: $language.skill) {
                ForEach(skillLevels, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.trailing, 15)
            .offset(x: -5)
        }
        .tint(.mint)
        .padding(.vertical, 15)
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .gray, radius: 1, x: 2, y: 2)
        .overlay(alignment: .topTrailing) {
            if isShowDeleteButton {
                Button {
                    isShowAlert.toggle()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.black)
                        .font(.title2)
                }
                .offset(x: 12, y: -15)
                .alert("確認", isPresented: $isShowAlert) {
                    Button("削除", role: .destructive) {
                        Task {
                            await viewModel.deleteSkillTag(id: $language.id.uuidString)
                            await viewModel.loadSkillTags()
                        }
                    }
                } message: {
                    Text("このタグを削除しますか？")
                }
            }
        }
        .sheet(isPresented: $isShowTechTags) {
            SkillTagPickerView(tags: viewModel.skillSortedTags, language: $language)
        }
    }
}
