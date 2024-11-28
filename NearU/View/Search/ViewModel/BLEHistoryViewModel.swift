//
//  SearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import Combine
import SwiftUI

@MainActor
class BLEHistoryViewModel: ObservableObject {
    @Published var historyRowData: [HistoryRowData] = []
    @Published var sortedHistoryRowData: [HistoryRowData] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchHistoryAllUsers(historyDataList: RealmManager.shared.historyData)
        }

        setupSubscribers()
    }

    //HistoryDataStructからUserHistoryRecordの配列を作成するメソッド
    func fetchHistoryAllUsers(historyDataList: [HistoryDataStruct]) async {
        var userHistoryRecords: [UserHistoryRecord] = []
        var addData: [HistoryRowData] = []
        do {
            let userIds = historyDataList.map { $0.userId }
            let dates = historyDataList.map { $0.date }
            let isReads = historyDataList.map { $0.isRead }
            let users = try await UserService.fetchUsers(userIds)
            // すべての配列のインデックスを利用してUserHistoryRecordを作成
            userHistoryRecords = (0..<users.count).map { index in
                UserHistoryRecord(user: users[index], date: dates[index], isRead: isReads[index])
            }

            for record in userHistoryRecords {
                let interestTags = try await UserService.fetchInterestTags(documentId: record.user.id)
                let isFollowed = await UserService.checkIsFollowed(receivedId: record.user.id)
                addData.append(HistoryRowData(record: record, tags: interestTags, isFollowed: isFollowed))
            }
            self.historyRowData = addData

        } catch {
            print("Error fetching users: \(error)")
        }
    }

    func markAsRead(_ pair: UserHistoryRecord) {
        RealmManager.shared.updateRead(pair.user.id)
    }

    func handleFollowButton(currentUser: User, pair: UserHistoryRecord) async throws {
        guard let fcmToken = pair.user.fcmtoken else { return }

        // プッシュ通知を送信
        try await NotificationManager.shared.sendPushNotification(
            fcmToken: fcmToken,
            username: currentUser.username,
            documentId: currentUser.id,
            date: pair.date
        )
        // フォロー処理を実行
        try await UserService.followUser(receivedId: pair.user.id, date: pair.date)
        RealmManager.shared.removeData(pair.user.id)
    }

    func setupSubscribers() {
        RealmManager.shared.$historyData
            .sink { [weak self] historyDataList in
                guard let self = self else { return }
                Task {
                    await self.fetchHistoryAllUsers(historyDataList: historyDataList)
                }
            }
            .store(in: &cancellables)

        $historyRowData
            .map { records in
                records.sorted { (a: HistoryRowData, b: HistoryRowData) -> Bool in
                    if a.record.isRead == b.record.isRead {
                        return a.record.date > b.record.date  // date が新しいもの順にソート
                    }
                    return !a.record.isRead && b.record.isRead
                }
            }
            .assign(to: &$sortedHistoryRowData)

    }
}




