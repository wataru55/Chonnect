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
        //ユーザーブロックのフィルタリングに支障を来たすから一旦コメントアウト
        //observeFirestoreChanges()
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
        
        do {
            try await BlockUserManager.shared.loadAllBlockData()
            
            let historyDataList = await loadHistoryData()
            let filteredHistoryData = BlockUserManager.shared.filterBlockedUsers(dataList: historyDataList)
            
            guard !filteredHistoryData.isEmpty else {
                self.historyRowData = []
                isLoading = false
                return
            }
            
            let userHistoryRecords = try await createUserHistoryRecords(historyDataList: filteredHistoryData)
            let historyRowDataList = try await fetchHistoryRowData(records: userHistoryRecords)
            
            self.historyRowData = historyRowDataList
        } catch {
            print("error: \(error)")
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
                print("Error listening to Firestore collection: \(error?.localizedDescription ?? "")")
                return
            }
            
            for change in snapshot.documentChanges {
                switch change.type {
                case .added:
                    self.handleAddedDocument(document: change.document)
                case .modified:
                    self.handleModifiedDocument(document: change.document)
                case .removed:
                    self.handleRemovedDocument(document: change.document)
                }
            }
        }
    }

    // ドキュメントが追加されたときの処理
    private func handleAddedDocument(document: QueryDocumentSnapshot) {
        let newHistoryData = try? document.data(as: HistoryDataStruct.self)
        if let data = newHistoryData {
            Task {
                // 必要な追加データをフェッチし、`historyRowData` に追加
                let user = try await UserService.fetchUser(withUid: data.userId)
                let interestTags = try await UserService.fetchInterestTags(documentId: data.userId)
                let isFollowed = await UserService.checkIsFollowed(receivedId: data.userId)
                let record = UserHistoryRecord(user: user, date: data.date, isRead: data.isRead)
                let rowData = HistoryRowData(record: record, tags: interestTags, isFollowed: isFollowed)
                
                // メインスレッドで更新
                await MainActor.run {
                    self.historyRowData.append(rowData)
                }
            }
        }
    }

    // ドキュメントが変更されたときの処理
    private func handleModifiedDocument(document: QueryDocumentSnapshot) {
        let modifiedHistoryData = try? document.data(as: HistoryDataStruct.self)
        if let data = modifiedHistoryData {
            Task {
                if let index = self.historyRowData.firstIndex(where: { $0.record.user.id == data.userId }) {
                    let interestTags = try await UserService.fetchInterestTags(documentId: data.userId)
                    let isFollowed = await UserService.checkIsFollowed(receivedId: data.userId)
                    let updatedRecord = UserHistoryRecord(user: self.historyRowData[index].record.user, date: data.date, isRead: data.isRead)
                    let updatedRowData = HistoryRowData(record: updatedRecord, tags: interestTags, isFollowed: isFollowed)
                    
                    // メインスレッドで更新
                    await MainActor.run {
                        self.historyRowData[index] = updatedRowData
                    }
                }
            }
        }
    }

    // ドキュメントが削除されたときの処理
    private func handleRemovedDocument(document: QueryDocumentSnapshot) {
        let removedUserId = document.documentID
        if let index = self.historyRowData.firstIndex(where: { $0.record.user.id == removedUserId }) {
            // メインスレッドで削除
            Task {
                await MainActor.run {
                    self.historyRowData.remove(at: index)
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
        
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] newBlockUserIds in
                guard let self = self else { return }
                
                self.historyRowData = self.historyRowData.filter { historyData in
                    !newBlockUserIds.contains(historyData.record.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }
    
    // ヘルパー関数
    /// UserHistoryRecordの作成
    private func createUserHistoryRecords(historyDataList: [HistoryDataStruct]) async throws -> [UserHistoryRecord] {
        let userIds = historyDataList.map { $0.userId }
        let dates = historyDataList.map { $0.date }
        let isReads = historyDataList.map { $0.isRead }
        
        let users = try await UserService.fetchUsers(userIds)
        
        return (0..<users.count).map { index in
            UserHistoryRecord(user: users[index], date: dates[index], isRead: isReads[index])
        }
    }
    
    /// HistoryRowDataの作成（並列処理）
    private func fetchHistoryRowData(records: [UserHistoryRecord]) async throws -> [HistoryRowData] {
        return try await withThrowingTaskGroup(of: HistoryRowData.self) { group in
            for record in records {
                group.addTask {
                    async let interestTags = UserService.fetchInterestTags(documentId: record.user.id)
                    async let isFollowed = UserService.checkIsFollowed(receivedId: record.user.id)
                    
                    return HistoryRowData(
                        record: record,
                        tags: try await interestTags,
                        isFollowed: await isFollowed
                    )
                }
            }
            
            var results: [HistoryRowData] = []
            for try await data in group {
                results.append(data)
            }
            return results
        }
    }
}




