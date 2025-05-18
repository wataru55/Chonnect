//
//  EditSkillTagsView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct EditSkillTagsView: View {
    @ObservedObject var viewModel: EditSkillTagsViewModel
    @Environment(\.dismiss) var dismiss

    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        //MARK: - タグの新規追加

                        Text("新規追加")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 5)
                            .padding(.vertical, 8)

                        Text("""
                        1：基本的な文法を学んだことがある程度
                        2：他者のサポートを受けつつ、小規模なタスクを実装できる
                        3：参考書やインターネットで調べながら、自身で実装を進められる
                        4：実装が複雑なアプリケーションを開発できる
                        5：テックリードとしてエンジニアを指導し、開発を進められる
                        """)
                        .font(.caption)
                        .foregroundStyle(.gray)

                        ForEach($viewModel.languages) { language in
                            SkillTagRowView(viewModel: viewModel,
                                            language: language,
                                            skillLevels: viewModel.skillLevels,
                                            isShowDeleteButton: false)
                            .padding(.top, 10)
                        } //foreach

                        Button(action: {
                            viewModel.languages.append(WordElement(id: UUID(), name: "", skill: "3"))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .offset(y: 3)
                                Text("入力欄を追加")
                                    .padding(.top, 5)
                                    .font(.system(size: 15, weight: .bold))

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

                        if viewModel.skillSortedTags.isEmpty {
                            Text("保存された技術タグがありません")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(spacing: 20){
                                ForEach($viewModel.skillSortedTags) { $language in
                                    SkillTagRowView(viewModel: viewModel,
                                                    language: $language,
                                                    skillLevels: viewModel.skillLevels,
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
                                    await viewModel.saveSkillTags()
                                    await MainActor.run {
                                        dismiss()
                                    }
                                }
                            } label: {
                                Text("保存")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.mint)
                            }
                        }
                    } //toolbar
                } //scrollview
                
                if viewModel.isLoading {
                    LoadingView()
                }
            } //zstack
            .modifier(EdgeSwipe())
        } // NavigationStack
        .onDisappear{
            viewModel.languages = [
                WordElement(id: UUID(), name: "", skill: "3")
            ]
        }
    }
}

#Preview {
    EditSkillTagsView(viewModel: EditSkillTagsViewModel())
}

