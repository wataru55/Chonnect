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
    
    private var userProvider: UserProvider?

    init() {
        Task {
            self.userProvider = try? await UserProvider()
            await fetchRealtimeAllUsers(realtimeDataList: RealtimeDataManager.shared.realtimeData)
        }
        setupSubscribers()
    }
    
    @MainActor
    func fetchRealtimeAllUsers(realtimeDataList: [EncountDataStruct]) async {
        do {
            // ブロックユーザーのデータをロード
            await BlockUserManager.shared.loadAllBlockData()
            
            // ブロックユーザーをフィルタリング
            let filteredRealtimeData = BlockUserManager.shared.filterBlockedUsers(dataList: realtimeDataList)
            
            // フィルタリング後のデータが空でないかチェック
            guard !filteredRealtimeData.isEmpty else {
                self.userRealtimeRecords = []
                return
            }
            
            self.userRealtimeRecords = try await makeUserRealtimeRecords(with: filteredRealtimeData)
        } catch {
            print("error: \(error)")
        }
    }

    func setupSubscribers() {
        RealtimeDataManager.shared.$realtimeData
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
        
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] newBlockUserIds in
                guard let self = self else { return }
                
                self.userRealtimeRecords = self.userRealtimeRecords.filter { record in
                    !newBlockUserIds.contains(record.pairData.user.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }
    
    private func makeUserRealtimeRecords(with realtimeDataList: [EncountDataStruct]) async throws -> [UserRealtimeRecord] {
        // Providerの準備
        guard let provider = self.userProvider else {
            print("UserProviderが準備できていません。")
            return []
        }
        // ユーザー情報を取得
        let fetchedUsers = try await provider.fetchUsers(with: realtimeDataList)

        // データの作成
        // ユーザー情報を高速に参照できるよう辞書に変換
        let userDictionary = fetchedUsers.reduce(into: [String: User]()) { $0[$1.id] = $1 }
        
        let result = realtimeDataList.compactMap { data -> UserRealtimeRecord? in
            if let user = userDictionary[data.userId] {
                return UserRealtimeRecord(pairData: UserDatePair(user: user, date: data.date), rssi: data.rssi)
            }
            return nil
        }
        
        return result
    }

}
