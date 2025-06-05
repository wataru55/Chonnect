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
            await loadArticle()
        }
    }

    func loadArticle() async {
        guard let documentId = AuthService.shared.currentUser?.id else {
            return
        }
        
        do {
            // Firestoreから記事URLを取得
            let articles = try await LinkService.fetchArticleLinks(withUid: documentId)

            for article in articles {
                let ogpData = await LinkService.fetchOpenGraphData(article: article)
                await MainActor.run {
                    self.openGraphData.append(ogpData)
                }
            }
            
        } catch {
            print("Error fetchArticleUrls: \(error)")
        }
    }

    func saveLink(urls: [String]) async throws {
        for url in urls {
            if !url.isEmpty {
                do {
                    let article = try await LinkService.saveArticleLink(url: url)
                    let ogpData = await LinkService.fetchOpenGraphData(article: article)
                    await MainActor.run {
                        self.openGraphData.append(ogpData)
                    }
                } catch {
                    print("Error adding URL to article collection: \(error)")
                }
            }
        }
    }

    func removeArticle(article: Article) async {
        // Firestoreから削除
        do {
            try await LinkService.deleteArticleLink(article: article)
        } catch {
            print("Error removing article: \(error)")
        }
        // UI更新
        await MainActor.run {
            if let index = openGraphData.firstIndex(where: { $0.article.url == article.url }) {
                openGraphData.remove(at: index)
            }
        }

    }
}
