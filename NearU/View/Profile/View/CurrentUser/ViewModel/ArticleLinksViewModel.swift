//
//  ArticleLinksLinksViewModel.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/16.
//

import Combine
import Firebase
import Foundation
import OpenGraph

class ArticleLinksViewModel: ObservableObject {
    @Published var articleUrls: [String] = [""]
    @Published var isShowAlert: Bool = false
    @Published var state: ViewState = .idle

    var errorMessage: String?
    private weak var currentUserProfileViewModel: CurrentUserProfileViewModel?

    // CurrentUserProfileViewModelのopenGraphDataを参照
    var openGraphData: [OpenGraphData] {
        return currentUserProfileViewModel?.openGraphData ?? []
    }

    var isUrlValid: Bool {
        Validation.validateArticleUrls(urls: articleUrls)
    }

    var isInputUrlsAllEmpty: Bool {
        articleUrls.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    // CurrentUserProfileViewModelを設定するメソッド
    func setCurrentUserProfileViewModel(_ viewModel: CurrentUserProfileViewModel) {
        self.currentUserProfileViewModel = viewModel
    }

    @MainActor
    func saveLink() async throws {
        self.state = .loading

        do {
            let articles = try await LinkService.saveArticleLink(urls: articleUrls)
            for article in articles {
                let ogpData = await LinkService.fetchOpenGraphData(article: article)
                currentUserProfileViewModel?.openGraphData.append(ogpData)
            }

            await currentUserProfileViewModel?.updateCache()
            self.articleUrls = [""]

        } catch let error as FireStoreSaveError {
            self.errorMessage = error.localizedDescription
            self.isShowAlert = true
            self.state = .idle
        }

        self.state = .success
    }

    @MainActor
    func removeArticle(article: Article) async {
        self.state = .loading

        do {
            try await LinkService.deleteArticleLink(article: article)

            // UI更新
            if let index = currentUserProfileViewModel?.openGraphData.firstIndex(where: {
                $0.article.url == article.url
            }) {
                currentUserProfileViewModel?.openGraphData.remove(at: index)
            }

            await currentUserProfileViewModel?.updateCache()
            self.state = .success

        } catch {
            self.errorMessage = error.localizedDescription
            self.isShowAlert = true
            self.state = .idle
        }
    }
}
