//
//  ProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/15.
//

import Foundation
import Firebase
import OpenGraph

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var currentUser: User
    @Published var selectedLanguageTags: [String] = []
    @Published var selectedFrameworkTags: [String] = []
    @Published var openGraphData: [OpenGraphData] = []

    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
        Task {
            try await loadLanguageTags()
            try await loadFrameworkTags()
            await fetchArticleLinks()
        }
    }

    @MainActor
    func loadUserData() async {
        do {
            let userSnapshot = try await Firestore.firestore().collection("users").document(user.id).getDocument()
            if let fetchedUser = try? userSnapshot.data(as: User.self) {
                self.user = fetchedUser
            }

            let currentUserSnapshot = try await Firestore.firestore().collection("users").document(currentUser.id).getDocument()
            if let fetchedCurrentUser = try? currentUserSnapshot.data(as: User.self) {
                self.currentUser = fetchedCurrentUser
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
        }
    }

    @MainActor
    func loadLanguageTags() async throws {
        do {
            let fetchedLanguageTags = try await UserService.fetchLanguageTags(withUid: user.id)
            self.selectedLanguageTags = fetchedLanguageTags.tags
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }

    @MainActor
    func loadFrameworkTags() async throws {
        do {
            let fetchedFrameworkTags = try await UserService.fetchFrameworkTags(withUid: user.id)
            self.selectedFrameworkTags = fetchedFrameworkTags.tags
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }

    @MainActor
    func fetchArticleLinks() async {
        do {
            let urls = try await UserService.fetchAbstractLinks(withUid: user.id)
            await getOpenGraphData(urls: urls)
        } catch {
            print("Error fetching article links: \(error)")
        }
    }

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
