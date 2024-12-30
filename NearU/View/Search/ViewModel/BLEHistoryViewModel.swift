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
    @Published var isLoading: Bool = true
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchHistoryAllUsers(historyDataList: RealmHistoryManager.shared.historyData)
            isLoading = false
        }

        setupSubscribers()
    }

    //HistoryDataStructからUserHistoryRecordの配列を作成するメソッド
    func fetchHistoryAllUsers(historyDataList: [HistoryDataStruct]) async {
        isLoading = true
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
        isLoading = false
    }

    func markAsRead(_ pair: UserHistoryRecord) {
        RealmHistoryManager.shared.updateRead(pair.user.id)
    }

    func setupSubscribers() {
        RealmHistoryManager.shared.$historyData
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




