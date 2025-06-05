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
    @Published var follows: [RowData] = []
    @Published var followers: [RowData] = []
    @Published var followCount: Int = 0
    @Published var followerCount: Int = 0
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
    
    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
    }

    func loadData() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.loadFollowCount()
                }
                group.addTask {
                    await self.loadFollowerCount()
                }
                group.addTask {
                    await self.loadSkillTags()
                }
                group.addTask {
                    await self.checkFollow()
                }
                group.addTask {
                    await self.checkFollowed()
                }
                group.addTask {
                    await self.fetchArticleLinks()
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
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
    func loadFollowCount() async {
        self.followCount = await FollowService.fetchFollowedUserCount(receivedId: user.id)
    }
    
    @MainActor
    func loadFollowerCount() async {
        self.followerCount = await FollowService.fetchFollowerCount(receivedId: user.id)
    }
    
    @MainActor
    func loadFollowUsers() async {
        do {
            let followedUsers = try await FollowService.fetchFollowedUsers(receivedId: user.id)
            let visibleFollowedUsers = BlockUserManager.shared.filterBlockedUsers(dataList: followedUsers)
            
            guard !visibleFollowedUsers.isEmpty else {
                self.follows = []
                return
            }
                
            var rows: [RowData] = []

            for followedUser in visibleFollowedUsers {
                let isFollowed = await FollowService.checkIsFollowed(receivedId: followedUser.user.id)
                let row = RowData(pairData: followedUser, isFollowed: isFollowed)
                rows.append(row)
            }

            self.follows = rows
        } catch {
            print("Error fetching follow users: \(error)")
        }
    }

    @MainActor
    func loadFollowers() async {
        do {
            let fetchedFollowers = try await FollowService.fetchFollowers(receivedId: user.id)
            let visibleFollowers = BlockUserManager.shared.filterBlockedUsers(dataList: fetchedFollowers)
            
            guard !visibleFollowers.isEmpty else {
                self.followers = []
                return
            }
            
            var followerRows: [RowData] = []

            for follower in visibleFollowers {
                let isFollowed = await FollowService.checkIsFollowed(receivedId: follower.user.id)
                let addData = RowData(pairData: follower, isFollowed: isFollowed)
                followerRows.append(addData)
            }

            self.followers = followerRows
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    @MainActor
    func fetchArticleLinks() async {
        do {
            let articles = try await LinkService.fetchArticleLinks(withUid: user.id)
            
            for article in articles {
                await getOpenGraphData(article: article)
            }
        } catch {
            print("Error fetching article links: \(error)")
        }
    }

    @MainActor
    private func getOpenGraphData(article: Article) async {
        guard let url = URL(string: article.url) else {
            let data = OpenGraphData(article: article, openGraph: nil)
            await MainActor.run {
                openGraphData.append(data)
            }
            return
        }
        
        do {
            let og = try await OpenGraph.fetch(url: url)
            let data = OpenGraphData(article: article, openGraph: og)
            await MainActor.run {
                openGraphData.append(data)
            }
        } catch {
            let data = OpenGraphData(article: article, openGraph: nil)
            await MainActor.run {
                openGraphData.append(data)
            }
        }
    }

    @MainActor
    func followUser(date: Date) async {
        guard let fcmToken = user.fcmtoken else { return }
        state = .loading
        do {
            // フォロー処理を実行
            try await CurrentUserActions.followUser(receivedId: user.id, date: date)
            await MainActor.run {
                self.isFollow = true
                self.followerCount += 1
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
                self.followerCount -= 1
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
