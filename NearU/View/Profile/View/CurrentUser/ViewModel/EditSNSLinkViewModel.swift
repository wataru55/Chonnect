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
    @Published var inputUrls: [String] = [""]
    @Published var isShowAlert: Bool = false
    @Published var state: ViewState = .idle
    
    var errorMessage: String?
    
    var isSNSLinkValid: Bool {
        Validation.validateSNSURL(urls: inputUrls)
    }
    
    var isInputUrlsAllEmpty: Bool {
        inputUrls.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }


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
    func updateSNSLink(urls: [String]) async {
        self.state = .loading
        
        var updateDict: [String: Any] = [:]
        
        for url in urls {
            if !url.isEmpty {
                let result = getServiceName(urlString: url)
                switch result {
                case .success(let serviceName):
                    updateDict["snsLinks.\(serviceName)"] = url
                case .failure(let error):
                    print("Error updateSNSLink: \(error)")
                    return
                }
            }
        }
        
        do {
            try await LinkService.saveSNSLink(updateDict: updateDict)
            for (field, value) in updateDict {
                // field = "snsLinks.{serviceName}", value = url
                let serviceName = field.replacingOccurrences(of: "snsLinks.", with: "")
                addSNSLinks(serviceName: serviceName, urlString: value as! String)
            }
            self.inputUrls = [""]
            self.state = .success
            
        } catch let error as FireStoreSaveError {
            self.state = .idle
            self.errorMessage = error.localizedDescription
            self.isShowAlert = true
        } catch {
            self.state = .idle
            self.errorMessage = "予期せぬエラーです"
            self.isShowAlert = true
        }
    }

    @MainActor
    func deleteSNSLink(serviceName: String, url: String) async {
        self.state = .loading
        do {
            try await LinkService.deleteSNSLink(serviceName: serviceName, url: url)
            snsUrls[serviceName] = nil // 該当のキーを削除
            self.state = .success
        
        } catch let error as FireStoreSaveError {
            self.state = .idle
            self.errorMessage = error.localizedDescription
            self.isShowAlert = true
        } catch {
            self.state = .idle
            self.errorMessage = "予期せぬエラーです"
            self.isShowAlert = true
        }
    }

    @MainActor
    func loadSNSLinks() async {
        let result = await CurrentUserService.loadCurrentUser()
        switch result {
        case .success(let user):
            self.snsUrls = user.snsLinks
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    
    }
    
    @MainActor
    func addSNSLinks(serviceName: String, urlString: String) {
        self.snsUrls[serviceName] = urlString
    }
}
