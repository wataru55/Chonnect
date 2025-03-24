//
//  TechTagPickerView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/23.
//

import SwiftUI

struct SkillTagPickerView: View {
    let tags: [WordElement]
    @Binding var language: WordElement
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSections: [String: Bool] = [:] // セクションの開閉状態を管理
    
    var techTags: [String: [String]] { SkillTagRepository.skillTags }
    var displayOrder: [String] { SkillTagRepository.displayOrder }
    var iconMapping: [String: String] { SkillTagRepository.iconMapping }

    var body: some View {
        NavigationView {
            List {
                ForEach(displayOrder, id: \.self) { category in
                    if let techs = techTags[category] { // 安全に辞書から値を取得
                        Section(header: HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    toggleSection(category)
                                }
                            }) {
                                HStack {
                                    Text(category)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .rotationEffect(.degrees(expandedSections[category] == true ? 90 : 0))
                                        .animation(.easeInOut(duration: 0.3), value: expandedSections[category])
                                        .foregroundColor(.gray)
                                }
                            }
                        }) {
                            if expandedSections[category] == true {
                                ForEach(techs, id: \.self) { tech in
                                    Button {
                                        language.name = tech
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        HStack {
                                            if let iconName = iconMapping[tech] {
                                                Image(iconName)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            Text(tech)
                                            Spacer()
                                            if tags.map({ $0.name }).contains(tech) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .disabled(tags.map({ $0.name }).contains(tech))
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
        .onAppear {
            // 初期状態で全セクションを閉じた状態に
            for category in techTags.keys {
                expandedSections[category] = false
            }
        }
    }

    private func toggleSection(_ category: String) {
        expandedSections[category]?.toggle()
    }
}
