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
    
    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
    }

    func loadData() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.loadFollowUsers()
                }
                group.addTask {
                    await self.loadFollowers()
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
    func loadFollowUsers() async {
        do {
            let followedUsers = try await FollowService.fetchFollowedUsers(receivedId: user.id)
            let visibleFollowedUsers = BlockUserManager.shared.filterBlockedUsers(dataList: followedUsers)
            
            guard !visibleFollowedUsers.isEmpty else {
                self.follows = []
                return
            }

            for followedUser in visibleFollowedUsers {
                self.follows.append(followedUser.user)
            }
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

            for follower in visibleFollowers {
                self.followers.append(follower.user)
            }
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
    func followUser(date: Date) async {
        guard let fcmToken = user.fcmtoken else { return }
        state = .loading
        do {
            // フォロー処理を実行
            try await CurrentUserActions.followUser(receivedId: user.id, date: date)
            await MainActor.run {
                self.isFollow = true
                // ToDo: フォローに成功した場合、自分をフォローリストに追加
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
                // ToDo: フォロー解除に成功した場合、自分をフォロワーリストからも削除
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
