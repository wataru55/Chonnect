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
    @Published var follows: [FollowUserRowData] = []
    @Published var followers: [HistoryRowData] = []
    @Published var skillSortedTags: [WordElement] = []
    @Published var interestSortedTags: [WordElement] = []
    @Published var interestTags: [InterestTag] = []
    @Published var isFollow: Bool = false
    @Published var isMutualFollow: Bool = false
    @Published var isLoading: Bool = true

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
                    await self.checkMutualFollow()
                }
                group.addTask {
                    await self.loadInterestTags()
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
    func checkFollow() async {
        let followsRef = Firestore.firestore().collection("users").document(currentUser.id).collection("follows")
        do {
            self.isFollow = try await followsRef.document(user.id).getDocument().exists

        } catch {
            self.isFollow = false
        }
    }

    @MainActor
    func checkMutualFollow() async {
        let followersRef = Firestore.firestore().collection("users").document(user.id).collection("follows")
        do {
            // 相手が自分をフォローしているかを確認
            let isFollower = try await followersRef.document(currentUser.id).getDocument().exists
            // 相互フォローを更新
            self.isMutualFollow = isFollow && isFollower
        } catch {
            // エラーが発生した場合は相互フォローと判定しない
            self.isMutualFollow = false
        }
        print("相互フォロー: \(isMutualFollow)")
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
    func loadInterestTags() async {
        do {
            let data = try await UserService.fetchInterestTags(documentId: user.id)
            self.interestTags = data
        } catch {
            print("error loading interest tags \(error.localizedDescription)")
        }
    }

    @MainActor
    func loadFollowUsers() async {
        do {
            let pairData = try await UserService.fetchFollowedUsers(receivedId: user.id)
            var followUserRowData: [FollowUserRowData] = []

            for data in pairData {
                let isFollowed = await UserService.checkIsFollowed(receivedId: data.user.id)
                let interestTags = try await UserService.fetchInterestTags(documentId: data.user.id)
                let addData = FollowUserRowData(pair: data, tags: interestTags, isFollowed: isFollowed)
                followUserRowData.append(addData)
            }

            self.follows = followUserRowData
        } catch {
            print("Error fetching follow users: \(error)")
        }
    }

    @MainActor
    func loadFollowers() async {
        do {
            let userHistoryRecords = try await UserService.fetchFollowers(receivedId: user.id)
            var historyRowData: [HistoryRowData] = []

            for record in userHistoryRecords {
                let isFollowed = await UserService.checkIsFollowed(receivedId: record.user.id)
                let interestTags = try await UserService.fetchInterestTags(documentId: record.user.id)
                let addData = HistoryRowData(record: record, tags: interestTags, isFollowed: isFollowed)
                historyRowData.append(addData)
            }

            self.followers = historyRowData
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    @MainActor
    func fetchArticleLinks() async {
        do {
            let urls = try await UserService.fetchArticleLinks(withUid: user.id)
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

    func followUser(date: Date) async throws{
        guard let fcmToken = user.fcmtoken else { return }
        do {
            // フォロー処理を実行
            try await UserService.followUser(receivedId: user.id, date: date)
            // プッシュ通知を送信
            try await NotificationManager.shared.sendPushNotification(
                fcmToken: fcmToken,
                username: currentUser.username,
                documentId: currentUser.id,
                date: date
            )
        } catch {
            throw error
        }
    }
}
