//
//  EditSkillTagsView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct EditSkillTagsView: View {
    @StateObject private var viewModel = EditSkillTagsViewModel()
    @State private var languages: [WordElement] = [
        WordElement(id: UUID(), name: "", skill: "3", interest: "")
    ]
    @Environment(\.dismiss) var dismiss
    private let availableLanguages = ["Swift", "Python", "C", "Java", "JavaScript"]
    private let skillLevels = ["1", "2", "3", "4", "5"]
    private let interestLevels = ["", "1", "2", "3", "4", "5"]

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach($viewModel.languages) { $language in
                            SkillTagRowView(language: $language,
                                            skillLevels: viewModel.skillLevels,
                                            interestLevels: viewModel.interestLevels)
                        } //foreach

                        Button(action: {
                            viewModel.languages.append(WordElement(id: UUID(),
                                                         name: "",
                                                         skill: "3", interest: ""))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("入力欄を追加")
                            }
                            .padding()
                            .foregroundColor(.mint)
                        }
                    }// vstack
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("技術タグの追加・削除")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.backward")
                                    .foregroundStyle(.black)
                            }
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                Task {
                                    await viewModel.saveSkillTags()
                                }
                            } label: {
                                HStack(spacing: 2) {
                                    Image(systemName: "plus.app")
                                    Text("保存")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(Color.mint)
                            }
                        }
                    } //toolbar
                } //scrollview
            } //zstack
        } // NavigationStack
    }
}

struct SkillTagRowView: View {
    @Binding var language: WordElement
    let skillLevels: [String]
    let interestLevels: [String]
    @State private var isShowTechTags: Bool = false

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

            Text("レベル")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            Picker("レベル", selection: $language.skill) {
                ForEach(skillLevels, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .offset(x: -5)

            Text("興味度")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.black)

            Picker("興味度", selection: $language.interest) {
                ForEach(interestLevels, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .offset(x: -5)
        }
        .tint(.mint)
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.7), radius: 2, x: 4, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 2)
        }
        .sheet(isPresented: $isShowTechTags) {
            TechTagPickerView(language: $language)
        }
    }
}


struct TechTagPickerView: View {
    let techTags: [String: [String]] = [
            "プログラミング言語": ["Swift", "Kotlin", "JavaScript", "Python","Go"],
            "フレームワーク": ["React", "Vue.js", "Angular", "Flutter", "SwiftUI", "tailwindcss"],
        ]
    @Binding var language: WordElement
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(techTags.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(techTags[category]!, id: \.self) { tech in
                            Button(action: {
                                language.name = tech
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(tech)
                                    Spacer()
                                    if tech == language.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("技術タグを選択")
            .navigationBarItems(trailing: Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            })
            .tint(.black)
        }
    }
}

#Preview {
    EditSkillTagsView()
}
