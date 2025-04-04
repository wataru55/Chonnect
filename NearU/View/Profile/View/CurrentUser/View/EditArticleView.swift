import SwiftUI

struct EditArticleView: View {
    @EnvironmentObject private var viewModel: ArticleLinksViewModel
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("記事のURLを追加")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.leading, 5)
                            .padding(.vertical, 10)
                        
                        if !viewModel.isUrlValid {
                            Text("適切でないURLが含まれています")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 5)
                        }
                        
                        VStack(spacing: 3) {
                            ForEach(viewModel.articleUrls.indices, id: \.self) { index in
                                TextField("URLを入力", text: $viewModel.articleUrls[index])
                                    .textInputAutocapitalization(.never) // 自動で大文字にしない
                                    .disableAutocorrection(true) // スペルチェックを無効にする
                                    .font(.subheadline)
                                    .padding(12)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 10)
                            }
                            
                            Button {
                                viewModel.articleUrls.append("")
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .offset(y: 3)
                                    Text("入力欄を追加")
                                        .padding(.top, 5)
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundStyle(Color.mint)
                            }// label
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)
                            
                            Text("記事一覧")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 5)
                                .padding(.vertical, 10)
                            
                            VStack(alignment: .center, spacing: 20) {
                                if viewModel.openGraphData.isEmpty {
                                    Text("記事のリンクがありません")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ForEach(viewModel.openGraphData) { openGraphData in
                                        SiteLinkButtonView(ogpData: openGraphData, showDeleteButton: true)
                                            .environmentObject(viewModel)
                                            .padding(.horizontal, 10)
                                    }
                                }
                            } //vstack
                            .padding(.bottom, 10)
                        } // vstack
                    } //vstack
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("記事の追加・削除")
                }
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
                                try await viewModel.addLink(urls: viewModel.articleUrls)
                                await viewModel.fetchArticleUrls()
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("追加")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(viewModel.isUrlValid && !viewModel.isInputUrlsAllEmpty ? Color.mint : Color.gray)
                        }
                        .disabled(!viewModel.isUrlValid || viewModel.isInputUrlsAllEmpty)
                    }
                }
            } //zstach
            .modifier(EdgeSwipe())
        } // navigationstack
        .onDisappear {
            viewModel.articleUrls = [""]
        }
    }
}

#Preview {
    EditArticleView()
        .environmentObject(ArticleLinksViewModel())
}

