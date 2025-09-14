//
//  EditProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import Combine
import Firebase
import PhotosUI
import SwiftUI

class CurrentUserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var followUsers: [User] = []
    @Published var followers: [User] = []
    @Published var skillSortedTags: [WordElement] = []
    @Published var openGraphData: [OpenGraphData] = []

    private var userProfileRepo: UserProfileRepository?
    private var cancellables = Set<AnyCancellable>()

    init() {
        if let currentUser: User = AuthService.shared.currentUser {
            self.user = currentUser
        } else {
            self.user = User(
                id: "", uid: "", username: "", isPrivate: false, snsLinks: [:], attributes: [],
                interestTags: [])
        }

        setupSubscribers()

        Task {
            self.userProfileRepo = try? await UserProfileRepository()
            await loadCurrentUserProfileData()
        }
    }

    func loadCurrentUserProfileData() async {
        guard let repo: UserProfileRepository = userProfileRepo,
            let currentUser = AuthService.shared.currentUser
        else {
            print("🚫 RepositoryまたはcurrentUserが準備できていません。")
            return
        }

        let result: CacheResult = await repo.fetch(userId: currentUser.id)

        switch result {
        case .fresh(let data):
            print("✅ CurrentUserの新鮮なキャッシュを利用します")
            await updateUI(with: data)

        case .stale(let data):
            print("⚠️ CurrentUserの古いキャッシュを先に表示します")
            await updateUI(with: data)

            print("⏳ 裏側で最新データの取得を開始します...")
            await fetchFromNetworkAndCache()

        case .notFound:
            print("�� CurrentUserのキャッシュがないため、最新データを取得します")
            await fetchFromNetworkAndCache()
        }
    }

    func updateCache() async {
        guard let repo = userProfileRepo else { return }

        let currentProfileData = ProfileData(
            user: user,
            follows: followUsers,
            followers: followers,
            skillTags: skillSortedTags,
            ogp: openGraphData.map { ($0.article, $0.openGraphSource) }
        )

        await repo.saveOrUpdate(profileData: currentProfileData)
        print("✅ キャッシュを更新しました")
    }

    @MainActor
    private func updateUI(with data: ProfileData) {
        // フォロー・フォロワーデータをUserDatePairに変換
        self.followUsers = data.follows
        self.followers = data.followers
        self.skillSortedTags = data.skillTags
        self.openGraphData = data.ogp.map {
            OpenGraphData(article: $0.article, openGraphSource: $0.openGraphSource)
        }
    }

    private func fetchFromNetworkAndCache() async {
        guard let currentUser = AuthService.shared.currentUser else { return }

        do {
            let allData = try await withThrowingTaskGroup(
                of: ProfileDataPartial.self, returning: ProfileData.self
            ) { group in

                group.addTask { .follows(try await self.fetchFollowUsers()) }
                group.addTask { .followers(try await self.fetchFollowers()) }
                group.addTask { .skillTags(try await self.fetchSkillTags()) }
                group.addTask { .openGraphData(try await self.fetchArticleLinks()) }

                var partials: [ProfileDataPartial] = []
                for try await partial in group {
                    partials.append(partial)
                }

                return ProfileData(
                    partials: partials,
                    initial: ProfileData(
                        user: currentUser,
                        follows: [],
                        followers: [],
                        skillTags: [],
                        ogp: []
                    ))
            }

            await updateUI(with: allData)
            await userProfileRepo?.saveOrUpdate(profileData: allData)
            print("✅ CurrentUserの最新データを取得し、キャッシュを更新しました")

        } catch {
            print("‼️ CurrentUserのネットワークからのデータ取得に失敗しました: \(error)")
        }
    }

    private func fetchFollowUsers() async throws -> [User] {
        guard let provider: UserProvider = try? await UserProvider() else {
            print("UserProviderが準備できていません。")
            return []
        }
        let followsData: [HistoryDataStruct] = try await FollowService.fetchFollowedUsers(
            receivedId: "")
        return try await provider.fetchUsers(with: followsData)
    }

    private func fetchFollowers() async throws -> [User] {
        guard let provider: UserProvider = try? await UserProvider() else {
            print("UserProviderが準備できていません。")
            return []
        }
        let followersData: [HistoryDataStruct] = try await FollowService.fetchFollowers(
            receivedId: "")
        return try await provider.fetchUsers(with: followersData)
    }

    private func fetchSkillTags() async throws -> [WordElement] {
        guard let documentId = AuthService.shared.currentUser?.id else {
            return []
        }
        let tags: [WordElement] = try await TagsService.fetchTags(documentId: documentId)
        return tags.sorted { $0.skill > $1.skill }
    }

    private func fetchArticleLinks() async throws -> [OpenGraphData] {
        guard let documentId: String = AuthService.shared.currentUser?.id else {
            return []
        }

        let articles: [Article] = try await LinkService.fetchArticleLinks(withUid: documentId)
        guard !articles.isEmpty else { return [] }

        return try await withThrowingTaskGroup(
            of: OpenGraphData.self, returning: [OpenGraphData].self
        ) { group in
            for article in articles {
                group.addTask {
                    return await LinkService.fetchOpenGraphData(article: article)
                }
            }

            var uniqueOgpDataDict: [String: OpenGraphData] = [:]

            for try await ogpData in group {
                uniqueOgpDataDict[ogpData.id] = ogpData
            }

            return Array(uniqueOgpDataDict.values)
        }
    }

    private func setupSubscribers() {
        AuthService.shared.$currentUser
            .compactMap({ $0 })
            .sink { [weak self] currentUser in
                self?.user = currentUser
            }
            .store(in: &cancellables)
    }
}
