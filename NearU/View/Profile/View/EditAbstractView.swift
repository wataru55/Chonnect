import SwiftUI

struct EditAbstractView: View {
    @EnvironmentObject private var viewModel: ArticleLinksViewModel
    @State private var articleUrls: [String] = [""]
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("記事のURLを追加")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding(.leading, 5)
                        .padding(.vertical, 10)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 3) {
                            ForEach(articleUrls.indices, id: \.self) { index in
                                TextField("URLを入力", text: $articleUrls[index])
                                    .textInputAutocapitalization(.never) // 自動で大文字にしない
                                    .disableAutocorrection(true) // スペルチェックを無効にする
                                    .font(.subheadline)
                                    .padding(12)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button {
                                articleUrls.append("")
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .offset(y: 3)
                                    Text("URLを追加")
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

                            VStack(spacing: 20) {
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
                                    }
                                }
                            } //vstack
                            .padding(.leading)
                            .padding(.bottom, 10)
                        } // vstack
                    } // scrollview
                } //vstack
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("記事の追加・削除")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.backward")
                            .onTapGesture {
                                dismiss()
                            }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                try await viewModel.addLink(urls: articleUrls)
                                await viewModel.fetchArticleUrls()
                                await MainActor.run {
                                    articleUrls = [""]
                                }
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "plus.app")
                                Text("追加")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(Color.mint)
                        }
                    }
                }
            } //zstach
        } // navigationstack
    }
}

#Preview {
    EditAbstractView()
        .environmentObject(ArticleLinksViewModel())
}

