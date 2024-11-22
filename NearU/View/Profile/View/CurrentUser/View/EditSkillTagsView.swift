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

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        //MARK: - タグの新規追加

                        Text("新規追加")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5)
                            .padding(.vertical, 5)

                        ForEach($languages) { language in
                            SkillTagRowView(language: language,
                                            skillLevels: viewModel.skillLevels,
                                            interestLevels: viewModel.interestLevels,
                                            isShowDeleteButton: false)
                        } //foreach

                        Button(action: {
                            languages.append(WordElement(id: UUID(),
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
                        //MARK: - 保存したタグ一覧

                        Text("技術タグ一覧")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5)
                            .padding(.vertical, 10)

                        if viewModel.languages.isEmpty {
                            Text("保存された技術タグがありません")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(spacing: 20){
                                ForEach($viewModel.languages) { $language in
                                    SkillTagRowView(language: $language,
                                                    skillLevels: viewModel.skillLevels,
                                                    interestLevels: viewModel.interestLevels,
                                                    isShowDeleteButton: true)
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            Task {
                                                await viewModel.deleteSkillTag(id: language.id.uuidString)
                                                await viewModel.loadSkillTags()

                                            }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(.black)
                                                .font(.title2)
                                        }
                                        .offset(x: 12, y: -15)
                                    }
                                } //foreach
                            }
                        }

                    }// vstack
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("技術タグの編集")
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
                                    await viewModel.saveSkillTags(newlanguages: languages)
                                    await MainActor.run {
                                        languages = [WordElement(id: UUID(),
                                                                 name: "",
                                                                 skill: "3", interest: "")]
                                    }
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
    @State private var isShowTechTags: Bool = false
    @Binding var language: WordElement
    let skillLevels: [String]
    let interestLevels: [String]
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
        .padding(.vertical, 15)
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.5), radius: 1, x: 4, y: 4)
        .overlay(alignment: .topTrailing) {
            if isShowDeleteButton {
                Button {

                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.black)
                        .font(.title2)
                }
                .offset(x: 12, y: -15)
            }
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
