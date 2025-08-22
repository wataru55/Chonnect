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
    @Published var isLoading: Bool = true
    @Published var isShowMarker: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var listenerRegistration: ListenerRegistration?
    private var isFirstLoad = true
    
    private var userProvider: UserProvider?

    init() {
        setupSubscribers()
        observeFirestoreChanges()
        
        Task {
            self.userProvider = try? await UserProvider()
            await makeHistoryRowData()
        }
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
            // ブロックユーザーのデータをロード
            await BlockUserManager.shared.loadAllBlockData()
            
            // Firestoreから履歴データを取得
            let historyDataList = await loadHistoryData()
            let userDatePair = try await createUserDatePair(historyDataList: historyDataList)
            
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
    
    private func createUserDatePair(historyDataList: [HistoryDataStruct]) async throws -> [UserDatePair] {
        // Repositoryの準備
        guard let provider = userProvider else {
            print("Providerが準備できていません。")
            return []
        }
        
        let fetchedUsers = try await provider.fetchUsers(with: historyDataList)
        
        // 日付情報とユーザー情報を結合して、最終的なリストを作成
        // 高速で結合するために、ユーザー情報を一時的に辞書に変換
        let userDictionary = fetchedUsers.reduce(into: [String: User]()) { $0[$1.id] = $1 }
        
        return historyDataList.compactMap { history in
            if let user = userDictionary[history.userId] {
                return UserDatePair(user: user, date: history.date)
            }
            return nil
        }
    }
}




