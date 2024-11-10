import SwiftUI

struct EditAbstractView: View {
    @EnvironmentObject private var viewModel: ArticleLinksViewModel
    @State private var articleUrls: [String] = [""]
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(articleUrls.indices, id: \.self) { index in
                        TextField("URLを入力", text: $articleUrls[index])
                            .modifier(URLFieldModifier())
                    }

                    Button {
                        articleUrls.append("")
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("URLを追加")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }// label
                } header: {
                    Text("記事のURLを追加")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .offset(x: -15)
                        .padding(.bottom, 10)
                } //header

                Section {
                    if viewModel.openGraphData.isEmpty {
                        Text("リンクがありません")
                            .foregroundColor(.orange)
                            .padding()
                    } else {
                        ForEach(viewModel.openGraphData) { openGraphData in
                            SiteLinkButtonView(ogpData: openGraphData, showDeleteButton: true, isOpenURL: false)
                                .environmentObject(viewModel)
                        }
                    }
                } header: {
                    Text("リンク一覧")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .offset(x: -15)
                }
            } //Form
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("記事の追加・削除")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .onTapGesture {
                            isPresented = false
                        }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try await viewModel.addLink(urls: articleUrls)
                            await viewModel.fetchArticleUrls()
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.down")
                            Text("追加")
                                .fontWeight(.bold)
                                .offset(y: 3)
                        }
                    }

                }
            }
        } // navigationstack
    }
}

#Preview {
    EditAbstractView(isPresented: .constant(true))
        .environmentObject(ArticleLinksViewModel())
}

