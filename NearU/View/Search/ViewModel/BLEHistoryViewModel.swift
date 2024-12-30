//
//  SearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import Combine
import SwiftUI
import Firebase

@MainActor
class BLEHistoryViewModel: ObservableObject {
    @Published var historyRowData: [HistoryRowData] = []
    @Published var sortedHistoryRowData: [HistoryRowData] = []
    @Published var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private var listenerRegistration: ListenerRegistration?

    init() {
        Task {
            await makeHistoryRowData()
            isLoading = false
        }

        setupSubscribers()
        observeFirestoreChanges()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func loadHistoryData() async -> [HistoryDataStruct] {
        do {
            return try await HistoryService.fetchHistoryUser()
        } catch {
            return []
        }
    }

    //HistoryDataStructからUserHistoryRecordの配列を作成するメソッド
    func makeHistoryRowData() async {
        isLoading = true
        var userHistoryRecords: [UserHistoryRecord] = []
        var addData: [HistoryRowData] = []
        
        let historyDataList = await loadHistoryData()
        guard !historyDataList.isEmpty else {
            isLoading = false
            return
        }
        
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

    func markAsRead(_ pair: UserHistoryRecord) async {
        do {
            try await HistoryService.changeIsRead(userId: pair.user.id)
        } catch {
            print("error marking history as read: \(error.localizedDescription)")
        }
    }
    
    private func observeFirestoreChanges() {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let docRef = Firestore.firestore()
            .collection("users")
            .document(documentId)
            .collection("history")
        
        listenerRegistration = docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else {
                // エラー処理など
                print("Error listening to Firestore collection: \(error?.localizedDescription ?? "")")
                return
            }
            
            // 変更のあったドキュメントのみを参照し、更新がある場合はデータをリロード
            if !snapshot.documentChanges.isEmpty {
                Task {
                    // Firestore 側で何かしらの変更があったので最新データを取り直す
                    await self.makeHistoryRowData()
                }
            }
        }
    }

    func setupSubscribers() {
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




