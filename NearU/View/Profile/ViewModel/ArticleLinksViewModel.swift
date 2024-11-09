//
//  AbstractLinksViewModel.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/16.
//

import Foundation
import Firebase
import OpenGraph
import Combine

class ArticleLinksViewModel: ObservableObject {
    @Published var selectedSNS: String = ""
    @Published var snsUrl: String = ""
    @Published var articleUrls: [String] = []
    @Published var openGraphData: [OpenGraphData] = []
    private var cancellable: AnyCancellable?

    init() {
        Task {
            await fetchArticleUrls()
        }
    }

    func fetchArticleUrls() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        do {
            let snapshot = try await Firestore.firestore().collection("users").document(userId).collection("abstract").getDocuments()

            // Firestoreから取得した記事URLを配列として返す
            let urls = snapshot.documents.compactMap { $0.data()["abstract_url"] as? String }

            await getOpenGraphData(urls: urls)

        } catch {
            print("Error fetchArticleUrls: \(error)")
        }
    }

    func addLink() async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        // SNSリンクが入力されている場合の更新
        if !selectedSNS.isEmpty && !snsUrl.isEmpty {
            let data = ["snsLinks.\(selectedSNS)": snsUrl]

            try await Firestore.firestore().collection("users").document(userId).updateData(data)
            print("SNSリンクの更新完了")
        }

        // 複数のURLが入力されている場合の更新
        for url in articleUrls {
            if !url.isEmpty {
                do {
                    try await UserService.seveArticleLink(userId: userId, url: url)
                } catch {
                    print("Error adding URL to abstract collection: \(error)")
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
}