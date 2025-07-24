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
    @Published var historyRowData: [UserDatePair] = []
    @Published var sortedHistoryRowData: [UserDatePair] = []
    @Published var isLoading: Bool = false
    @Published var isShowMarker: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var listenerRegistration: ListenerRegistration?
    private var isFirstLoad = true

    init() {
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

    //HistoryDataStructからUserDatePairの配列を作成するメソッド
    func makeHistoryRowData() async {
        isLoading = true
        
        do {
            await BlockUserManager.shared.loadAllBlockData()
            
            let historyDataList = await loadHistoryData()
            let filteredHistoryData = BlockUserManager.shared.filterBlockedUsers(dataList: historyDataList)
            
            guard !filteredHistoryData.isEmpty else {
                self.historyRowData = []
                isLoading = false
                return
            }
            
            let userDatePair = try await createUserDatePair(historyDataList: filteredHistoryData)
            
            self.historyRowData = userDatePair
            self.isShowMarker = false
        } catch {
            print("error: \(error)")
        }
        
        isLoading = false
    }
    
    private func observeFirestoreChanges() {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let docRef = Firestore.firestore()
            .collection("users")
            .document(documentId)
            .collection("history")
        
        listenerRegistration?.remove()
        
        listenerRegistration = docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else {
                print("Error listening to Firestore collection: \(error?.localizedDescription ?? "")")
                return
            }
            
            // 初回ロード時のイベントかチェック
            if self.isFirstLoad {
                self.isFirstLoad = false
                return
            }
            
            for change in snapshot.documentChanges {
                switch change.type {
                case .added:
                    self.isShowMarker = true
                default:
                    break
                }
            }
        }
    }

    func setupSubscribers() {
        $historyRowData
            .map { records in
                records.sorted { (a: UserDatePair, b: UserDatePair) -> Bool in
                    return a.date > b.date  // date が新しいもの順にソート
                }
            }
            .assign(to: &$sortedHistoryRowData)
        
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] newBlockUserIds in
                guard let self = self else { return }
                
                self.historyRowData = self.historyRowData.filter { historyData in
                    !newBlockUserIds.contains(historyData.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }
    
    // ヘルパー関数
    /// UserDatePairの作成
    private func createUserDatePair(historyDataList: [HistoryDataStruct]) async throws -> [UserDatePair] {
        let userIds = historyDataList.map { $0.userId }
        let dates = historyDataList.map { $0.date }
        
        let users = try await UserService.fetchUsers(userIds)
        
        return (0..<users.count).map { index in
            UserDatePair(user: users[index], date: dates[index])
        }
    }
}




