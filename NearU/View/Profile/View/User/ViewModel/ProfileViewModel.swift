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
    @Published var openGraphData: [OpenGraphData] = []
    @Published var follows: [User] = []
    @Published var followers: [User] = []
    @Published var skillSortedTags: [WordElement] = []
    @Published var isFollow: Bool = false
    var isFollowed: Bool = false
    
    @Published var isLoading: Bool = true
    @Published var isShowAlert: Bool = false
    @Published var errorMessage: String?
    @Published var state: ViewState = .idle
    
    var isMutualFollow: Bool {
        isFollow && isFollowed
    }
    
    var isMyProfile: Bool {
        user.id == currentUser.id
    }
    
    private var profileData: ProfileData {
        .init(
            user: self.user,
            follows: self.follows,
            followers: self.followers,
            skillTags: self.skillSortedTags,
            ogp: self.openGraphData.map { ($0.article, $0.openGraphSource) }
        )
    }
    
    // Repositoryをプロパティとして保持
    private var userProfileRepo: UserProfileRepository?
    private var userProvider: UserProvider?
    
    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
        
        Task {
            self.userProfileRepo = try? await UserProfileRepository()
            self.userProvider = try? await UserProvider()
        }
    }

    func loadData() async {
        guard let repo = userProfileRepo else {
            print("🚫 Repositoryがまだ準備できていません。")
            self.isLoading = false
            return
        }
        
        let result = await repo.fetch(userId: user.id)
        
        switch result {
        case .fresh(let data):
            print("✅ 新鮮なキャッシュを利用します")
            await updateUI(with: data)
            
        case .stale(let data):
            print("⚠️ 古いキャッシュを先に表示します")
            await updateUI(with: data)
            
            print("⏳ 裏側で最新データの取得を開始します...")
            await fetchFromNetworkAndCache()
            
        case .notFound:
            print("🚫 キャッシュがないため、最新データを取得します")
            await fetchFromNetworkAndCache()
        }
        
        // 最後にローディング表示を解除
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    @MainActor
    private func updateUI(with data: ProfileData) {
        self.user = data.user
        self.follows = data.follows
        self.followers = data.followers
        self.skillSortedTags = data.skillTags
        // OGPデータも反映
        self.openGraphData = data.ogp.map { OpenGraphData(article: $0.article, openGraphSource: $0.openGraphSource) }
        // フォロー状態のチェックはリアルタイム性が高いので別途実行
        Task {
            await checkFollow()
            await checkFollowed()
        }
    }
    
    // ネットワークからデータを取得し、キャッシュに保存する
    private func fetchFromNetworkAndCache() async {
        do {
            // withThrowingTaskGroupを使い、エラーハンドリングを可能に
            let allData = try await withThrowingTaskGroup(of: ProfileDataPartial.self, returning: ProfileData.self) { group in
                
                // 各データ取得タスクを追加。結果を返すように変更
                group.addTask { .follows(try await self.fetchFollowUsers()) }
                group.addTask { .followers(try await self.fetchFollowers()) }
                group.addTask { .skillTags(try await self.fetchSkillTags()) }
                group.addTask { .openGraphData(try await self.fetchArticleLinks()) }
                
                // TaskGroupの結果を集約
                var partials: [ProfileDataPartial] = []
                for try await partial in group {
                    partials.append(partial)
                }
                
                // ProfileDataを構築（不足分は現在の値で補う）
                return ProfileData(partials: partials, initial: self.profileData)
            }
            
            // 全てのデータが揃ってから、一度だけUIを更新
            await updateUI(with: allData)
            
            // 全てのデータが揃ってから、一度だけキャッシュを更新
            await userProfileRepo?.saveOrUpdate(profileData: allData)
            print("✅ 最新データを取得し、キャッシュを更新しました")
            
        } catch {
            print("‼️ ネットワークからのデータ取得に失敗しました: \(error)")
        }
    }

    @MainActor
    // 相手をフォローしているか確認
    func checkFollow() async {
        self.isFollow = await FollowService.checkIsFollowing(receivedId: user.id)
    }
    
    @MainActor
    // 相手にフォローされているか確認
    func checkFollowed() async {
        self.isFollowed = await FollowService.checkIsFollowed(receivedId: user.id)
    }
    
    private func fetchFollowUsers() async throws -> [User] {
        // followServiceのチェックを削除
        guard let provider = self.userProvider else { throw URLError(.badServerResponse) }
        
        // staticメソッドとして直接呼び出す
        let followsData = try await FollowService.fetchFollowedUsers(receivedId: user.id)
        
        return try await provider.fetchUsers(with: followsData)
    }
    
    private func fetchFollowers() async throws -> [User] {
        // followServiceのチェックを削除
        guard let provider = self.userProvider else { throw URLError(.badServerResponse) }
        
        // staticメソッドとして直接呼び出す
        let followersData = try await FollowService.fetchFollowers(receivedId: user.id)
        
        return try await provider.fetchUsers(with: followersData)
    }
    
    private func fetchSkillTags() async throws -> [WordElement] {
        let tags = try await TagsService.fetchTags(documentId: user.id)
        return tags.sorted { $0.skill > $1.skill }
    }

    private func fetchArticleLinks() async throws -> [OpenGraphData] {
        // 1. まず記事のリストを取得
        let articles = try await LinkService.fetchArticleLinks(withUid: user.id)
        guard !articles.isEmpty else { return [] }
        
        // 2. TaskGroupで、全ての記事のOGPデータを「並行」で取得
        return try await withThrowingTaskGroup(of: OpenGraphData.self, returning: [OpenGraphData].self) { group in
            
            for article in articles {
                group.addTask {
                    // LinkServiceからOGPデータを取得
                    return await LinkService.fetchOpenGraphData(article: article)
                }
            }
            
            var uniqueOgpDataDict: [String: OpenGraphData] = [:]
            
            // 全ての並行処理が終わるのを待ち、結果を集約
            for try await ogpData in group {
                uniqueOgpDataDict[ogpData.id] = ogpData
            }
            
            return Array(uniqueOgpDataDict.values)
        }
    }

    @MainActor
    func followUser(date: Date?) async {
        guard let date = date else { return }
        guard let fcmToken = user.fcmtoken else { return }
        state = .loading
        do {
            // フォロー処理を実行
            try await CurrentUserActions.followUser(receivedId: user.id, date: date)
            await MainActor.run {
                self.isFollow = true
                // フォローに成功した場合、自分をフォローリストに追加
                self.followers.append(currentUser)
                self.state = .success
            }
            // プッシュ通知を送信
            await NotificationManager.shared.sendPushNotification (
                fcmToken: fcmToken,
                username: currentUser.username,
                documentId: currentUser.id,
                date: date
            )
        } catch {
            self.errorMessage = "フォローに失敗しました"
            self.isShowAlert = true
            self.state = .idle
        }
    }
    
    @MainActor
    func unFollowUser() async {
        state = .loading
        do {
            // フォロー解除処理を実行
            try await CurrentUserActions.unFollowUser(receivedId: user.id)
            await MainActor.run {
                self.isFollow = false
                // フォロー解除に成功した場合、自分をフォロワーリストからも削除
                followers.removeAll { $0.id == currentUser.id }
                self.state = .success
                // 相互フォローも解除
            }
        } catch {
            self.errorMessage = "フォロー解除に失敗しました"
            self.isShowAlert = true
            self.state = .idle
        }
    }
}

// withTaskGroupの結果をまとめるためのヘルパーenumと、ProfileDataの拡張
enum ProfileDataPartial {
    case user(User)
    case follows([User])
    case followers([User])
    case skillTags([WordElement])
    case openGraphData([OpenGraphData])
}

extension ProfileData {
    init(partials: [ProfileDataPartial], initial: ProfileData) {
        var user = initial.user
        var follows = initial.follows
        var followers = initial.followers
        var skillTags = initial.skillTags
        var ogp = initial.ogp.map { OpenGraphData(article: $0.article, openGraphSource: $0.openGraphSource) }

        for partial in partials {
            switch partial {
            case .user(let value): user = value
            case .follows(let value): follows = value
            case .followers(let value): followers = value
            case .skillTags(let value): skillTags = value
            case .openGraphData(let value): ogp = value
            }
        }
        
        self.init(user: user, follows: follows, followers: followers, skillTags: skillTags, ogp: ogp.map { ($0.article, $0.openGraphSource) })
    }
}
