//
//  AddLinkViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/13.
//

import PhotosUI
import SwiftUI
import Firebase

class EditSNSLinkViewModel: ObservableObject {
    @Published var snsUrls: [String: String] = [:] // SNSリンクを保存

    init() {
        Task {
            await loadSNSLinks()
        }
    }

    /// サービスとその対応するホスト名のマッピング
    let serviceHostMapping: [String: [String]] = [
        "GitHub": ["github.com"],
        "X": ["twitter.com", "x.com"],
        "Instagram": ["instagram.com"],
        "YouTube": ["youtube.com", "youtu.be"],
        "Facebook": ["facebook.com"],
        "TikTok": ["tiktok.com"],
        "Qiita": ["qiita.com"],
        "Zenn": ["zenn.dev"],
        "Wantedly": ["wantedly.com"],
        "Linkedin": ["linkedin.com"],
        "Threads": ["threads.net"]
    ]

    private func getServiceName(urlString: String) -> Result<String, Error> {
        // URLとして有効かどうかを確認
        guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
            return .failure(URLError(.badURL))
        }
        // 各サービスのホスト名と比較
        for (service, hosts) in serviceHostMapping {
            for serviceHost in hosts {
                if host.contains(serviceHost) {
                    return .success(service)
                }
            }
        }

        return .success("link")
    }

    @MainActor
    func updateSNSLink(urls: [String]) async throws {
        for url in urls {
            if !url.isEmpty {
                let result = getServiceName(urlString: url)
                switch result {
                case .success(let serviceName):
                    try await UserService.saveSNSLink(serviceName: serviceName, url: url)
                    print("SNSリンクの更新完了")
                case .failure(let error):
                    print("Error updateSNSLink: \(error)")
                }
            }
        }
    }

    func deleteSNSLink(serviceName: String, url: String) async throws {
        do {
            try await UserService.deleteSNSLink(serviceName: serviceName, url: url)
        } catch {
            print("Error deleteSNSLink: \(error)")
        }
    }

    @MainActor
    func loadSNSLinks() async {
        do {
            try await AuthService.shared.loadUserData()
        } catch {
            print("Error loadUserData: \(error)")
        }
        guard let currentUser = AuthService.shared.currentUser else { return }

        self.snsUrls = currentUser.snsLinks
    }
}
