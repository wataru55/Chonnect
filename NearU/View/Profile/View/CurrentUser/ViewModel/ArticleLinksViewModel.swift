//
//  ArticleLinksLinksViewModel.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/16.
//

import Foundation
import Firebase
import OpenGraph
import Combine

class ArticleLinksViewModel: ObservableObject {
    @Published var openGraphData: [OpenGraphData] = []
    @Published var articleUrls: [String] = [""]
    
    var isUrlValid: Bool {
        Validation.validateArticleUrls(urls: articleUrls)
    }
    
    var isInputUrlsAllEmpty: Bool {
        articleUrls.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    init() {
        Task {
            await fetchArticleUrls()
        }
    }

    func fetchArticleUrls() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        do {
            let snapshot = try await Firestore.firestore().collection("users").document(userId).collection("article").getDocuments()

            // Firestoreから取得した記事URLを配列として返す
            let urls = snapshot.documents.compactMap { $0.data()["article_url"] as? String }

            await getOpenGraphData(urls: urls)

        } catch {
            print("Error fetchArticleUrls: \(error)")
        }
    }

    func addLink(urls: [String]) async throws {
        for url in urls {
            if !url.isEmpty {
                do {
                    try await UserService.seveArticleLink(url: url)
                } catch {
                    print("Error adding URL to article collection: \(error)")
                }
            }
        }
    }

    // urlからOGPを取得する
    @MainActor
    private func getOpenGraphData(urls: [String]) async {
        self.openGraphData = []

        for urlString in urls {
            guard let url = URL(string: urlString) else {
                let data = OpenGraphData(url: urlString, openGraph: nil)
                await MainActor.run {
                    openGraphData.append(data)
                }
                continue
            }

            do {
                let og = try await OpenGraph.fetch(url: url)
                let data = OpenGraphData(url: urlString, openGraph: og)
                await MainActor.run {
                    openGraphData.append(data)
                }
            } catch {
                let data = OpenGraphData(url: urlString, openGraph: nil)
                await MainActor.run {
                    openGraphData.append(data)
                }
            }
        }
    }

    func removeArticle(url: String) async {
        // Firestoreから削除
        do {
            print(url)
            try await UserService.deleteArticleLink(url: url)
        } catch {
            print("Error removing article: \(error)")
        }
        // UI更新
        await MainActor.run {
            if let index = openGraphData.firstIndex(where: { $0.url == url }) {
                openGraphData.remove(at: index)
            }
        }

    }
}
