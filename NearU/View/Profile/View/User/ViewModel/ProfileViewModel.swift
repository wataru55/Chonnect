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
    
    // Repositoryをプロパティとして保持
    private var userProfileRepo: UserProfileRepository?
    
    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
    }

    func loadData() async {
        if self.userProfileRepo == nil {
            print("🚀 Repositoryを初期化します...")
            self.userProfileRepo = try? await UserProfileRepository()
        }
        
        guard let repo = userProfileRepo else {
            print("🚫 Repositoryがまだ準備できていません。")
            await MainActor.run { self.isLoading = false }
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
        self.openGraphData = data.ogp.map { tuple in
            // 新しいinitに合わせて、辞書を直接渡す
            return OpenGraphData(article: tuple.article, openGraphSource: tuple.openGraphSource)
        }
        
        // フォロー状態のチェックはリアルタイム性が高いので別途実行
        Task {
            await checkFollow()
            await checkFollowed()
        }
    }
    
    // ネットワークからデータを取得し、キャッシュに保存する
    private func fetchFromNetworkAndCache() async {
        // ここに元のloadDataにあったwithTaskGroupの処理を入れる
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadFollowUsers() }
            group.addTask { await self.loadFollowers() }
            group.addTask { await self.loadSkillTags() }
            group.addTask { await self.checkFollow() }
            group.addTask { await self.checkFollowed() }
            group.addTask { await self.fetchArticleLinks() }
        }
        
        let latestData = ProfileData(user: self.user, follows: self.follows,
                                     followers: self.followers, skillTags: self.skillSortedTags,
                                     ogp: self.openGraphData.map { ($0.article, $0.openGraphSource) })
        
        // UIを最新データで更新
        await updateUI(with: latestData)
        
        // 最新データをキャッシュに保存
        await userProfileRepo?.saveOrUpdate(profileData: latestData)
        print("✅ 最新データを取得し、キャッシュを更新しました")
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
    func loadSkillTags() async {
        do {
            let tags = try await TagsService.fetchTags(documentId: user.id)
            self.skillSortedTags = tags.sorted { $0.skill > $1.skill }
        } catch {
            print("Error fetching tags: \(error)")
        }
    }
    
    @MainActor
    func loadFollowUsers() async {
        do {
            let followsData = try await FollowService.fetchFollowedUsers(receivedId: user.id)
            self.follows = try await UserProvider().fetchUsers(with: followsData)
            
        } catch {
            print("Error fetching follow users: \(error)")
        }
    }

    @MainActor
    func loadFollowers() async {
        do {
            let followersData = try await FollowService.fetchFollowers(receivedId: user.id)
            self.follows = try await UserProvider().fetchUsers(with: followersData)
            
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    func fetchArticleLinks() async {
        do {
            let articles = try await LinkService.fetchArticleLinks(withUid: user.id)
            
            for article in articles {
                let ogpData = await LinkService.fetchOpenGraphData(article: article)
                await MainActor.run {
                    self.openGraphData.append(ogpData)
                }
                
            }
        } catch {
            print("Error fetching article links: \(error)")
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
