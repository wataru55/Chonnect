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
    @Published var userHistoryRecords: [UserHistoryRecord] = []
    @Published var sortedUserHistoryRecords: [UserHistoryRecord] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchHistoryAllUsers(historyDataList: RealmManager.shared.historyData)
        }

        setupSubscribers()
    }

    //HistoryDataStructからUserHistoryRecordの配列を作成するメソッド
    func fetchHistoryAllUsers(historyDataList: [HistoryDataStruct]) async {
        do {
            let userIds = historyDataList.map { $0.userId }
            let dates = historyDataList.map { $0.date }
            let isReads = historyDataList.map { $0.isRead }
            let users = try await UserService.fetchUsers(userIds)
            // すべての配列のインデックスを利用してUserHistoryRecordを作成
            self.userHistoryRecords = (0..<users.count).map { index in
                UserHistoryRecord(user: users[index], date: dates[index], isRead: isReads[index])
            }
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

        $userHistoryRecords
            .map { records in
                records.sorted { !$0.isRead && $1.isRead }
            }
            .assign(to: &$sortedUserHistoryRecords)
    }
}




