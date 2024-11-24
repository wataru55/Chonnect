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
                            SkillTagRowView(viewModel: viewModel,
                                            language: language,
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

                        if viewModel.Tags.isEmpty {
                            Text("保存された技術タグがありません")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(spacing: 20){
                                ForEach($viewModel.Tags) { $language in
                                    SkillTagRowView(viewModel: viewModel,
                                                    language: $language,
                                                    skillLevels: viewModel.skillLevels,
                                                    interestLevels: viewModel.interestLevels,
                                                    isShowDeleteButton: true)
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
    @ObservedObject var viewModel: EditSkillTagsViewModel
    @State private var isShowTechTags: Bool = false
    @State private var isShowAlert: Bool = false
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
            TechTagPickerView(language: $language)
        }
    }
}


struct TechTagPickerView: View {
    let techTags: [String: [String]] = [
        "言語": ["Swift", "Kotlin", "JavaScript", "Python", "Go", "Java", "Ruby", "PHP", "TypeScript", "C", "C++", "C#", "HTML", "CSS", "Rust", "Dart", "Elixir"],
        "フレームワーク": ["React", "Next.js", "Vue", "Nuxt.js", "Angular", "Node.js", "Django", "Flask", "Laravel", "CakePHP", "Flutter", "Rails", "Remix", "Tailwind CSS", "Spring"],
        "データベース": ["MySQL", "PostgreSQL", "MongoDB", "Redis", "MariaDB", "DynamoDB"],
        "その他": ["AWS", "GCP", "Azure", "Cloudflare", "Vercel", "Firebase", "Supabase", "Terraform", "Unity", "Blender", "Docker", "ROS"],
    ]
    
    // 表示順を指定
    let displayOrder: [String] = ["言語", "フレームワーク", "データベース", "その他"]
    
    @Binding var language: WordElement
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSections: [String: Bool] = [:] // セクションの開閉状態を管理
    
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
                                    Button(action: {
                                        language.name = tech
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        HStack {
                                            if let iconName = iconMapping[tech] {
                                                Image(iconName)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
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
    
    private let iconMapping: [String: String] = [
        // 言語
        "JavaScript": "JavaScript",
        "Python": "Python",
        "Java": "Java",
        "Ruby": "Ruby",
        "Swift": "Swift",
        "PHP": "PHP",
        "TypeScript": "TypeScript",
        "Go": "Go",
        "C": "C",
        "C++": "C-plus",
        "Kotlin": "Kotlin",
        "C#": "C-sharp",
        "HTML": "HTML",
        "CSS": "CSS",
        "Rust": "Rust",
        "Dart": "Dart",
        "Elixir": "Elixir",
        // フレームワーク
        "React": "React",
        "Next.js": "Next-js",
        "Vue": "Vue",
        "Nuxt.js": "Nuxt-js",
        "Angular": "Angular",
        "Node.js": "Node-js",
        "Django": "Django",
        "Flask": "Flask",
        "Laravel": "Laravel",
        "CakePHP": "CakePHP",
        "Flutter": "Flutter",
        "Rails": "Rails",
        "Remix": "Remix",
        "Tailwind CSS": "Tailwind-CSS",
        "Spring": "Spring",
        // データベース
        "MySQL": "MySQL",
        "PostgreSQL": "PostgreSQL",
        "MongoDB": "MongoDB",
        "Redis": "Redis",
        "MariaDB": "MariaDB",
        "DynamoDB": "DynamoDB",
        // その他
        "AWS": "AWS",
        "GCP": "GCP",
        "Azure": "Azure",
        "Cloudflare": "Cloudflare",
        "Vercel": "Vercel",
        "Firebase": "Firebase",
        "Supabase": "Supabase",
        "Terraform": "Terraform",
        "Unity": "Unity",
        "Blender": "Blender",
        "Docker": "Docker",
        "ROS": "ROS"
    ]

}


#Preview {
    EditSkillTagsView()
}
