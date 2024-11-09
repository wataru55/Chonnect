//
//  BLERealtimeViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/06.
//

import SwiftUI
import Combine

@MainActor
class BLERealtimeViewModel: ObservableObject {
    @Published var userRealtimeRecords: [UserRealtimeRecord] = []
    @Published var sortedUserRealtimeRecords: [UserRealtimeRecord] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchRealtimeAllUsers(realtimeDataList: RealmManager.shared.realtimeData)
        }
        setupSubscribers()
    }

    func fetchRealtimeAllUsers(realtimeDataList: [EncountDataStruct]) async {
        do {
            let userIds = realtimeDataList.map { $0.userId }
            let dates = realtimeDataList.map { $0.date }
            let rssis = realtimeDataList.map { $0.rssi }
            let users = try await UserService.fetchUsers(userIds)
            self.userRealtimeRecords = (0..<users.count).map { index in
                UserRealtimeRecord(user: users[index], date: dates[index], rssi: rssis[index])
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }

    func handleFollowButton(currentUser: User, pair: UserRealtimeRecord) async throws {
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
        RealmManager.shared.$realtimeData
            .sink { [weak self] realtimeDataList in
                guard let self = self else { return }
                Task {
                    await self.fetchRealtimeAllUsers(realtimeDataList: realtimeDataList)
                }
            }
            .store(in: &cancellables)

        $userRealtimeRecords
            .map { records in
                records.sorted { $0.rssi > $1.rssi }
            }
            .assign(to: &$sortedUserRealtimeRecords)
    }

}
