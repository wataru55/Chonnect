//
//  EditSkillTagsView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct EditSkillTagsView: View {
    @State private var languages: [WordElement] = [
        WordElement(id: UUID(), name: "", skill: "3", interest: "")
    ]
    @State private var isShowTechTags: Bool = false
    private let availableLanguages = ["Swift", "Python", "C", "Java", "JavaScript"]
    private let skillLevels = ["1", "2", "3"]
    private let interestLevels = ["", "1", "2", "3"]

    var body: some View {
        VStack {
            ForEach($languages) { $language in
                SkillTagRowView(language: $language,
                                skillLevels: skillLevels,
                                interestLevels: interestLevels,
                                isShowTechTags: $isShowTechTags)
            } //foreach

            Button(action: {
                languages.append(WordElement(id: UUID(), name: "", skill: "3", interest: ""))
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("追加する")
                }
                .padding()
                .foregroundColor(.mint)
            }
        }// vstack
        .padding()
    }
}

struct SkillTagRowView: View {
    @Binding var language: WordElement
    let skillLevels: [String]
    let interestLevels: [String]
    @Binding var isShowTechTags: Bool

    var body: some View {
        HStack(spacing: 0) {
            Button {
                isShowTechTags.toggle()
            } label: {
                HStack {
                    Text(language.name.isEmpty ? "一覧" : language.name)
                        .foregroundColor(language.name.isEmpty ? .mint : .black)
                        .fontWeight(.bold)
                    Image(systemName: "text.justify")
                }
                .font(.footnote)
                .foregroundColor(language.name.isEmpty ? .mint : .black)
            }
            .frame(width: 100, height: 20)
            .offset(x: -20)

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
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.7), radius: 2, x: 4, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 2)
        }
    }
}


struct TechTagPickerView: View {
    let techTags: [String: [String]]
    @Binding var selectedTechTag: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(techTags.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(techTags[category]!, id: \.self) { tech in
                            Button(action: {
                                selectedTechTag = tech
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(tech)
                                    Spacer()
                                    if tech == selectedTechTag {
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
