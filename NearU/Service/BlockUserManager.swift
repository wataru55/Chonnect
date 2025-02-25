//
//  BlockUserManager.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/23.
//

import SwiftUI
import Firebase

final class BlockUserManager: ObservableObject {
    @Published var blockUserIds: [String] = []
    var blockedByUserIds: [String] = []
    
    static let shared = BlockUserManager()
    
    private init() {}
    
    /// ブロックした全ユーザーのidをフェッチ
    func loadBlockUserIds() async throws {
        guard let currentUserIds = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(currentUserIds).collection("blocks")
        
        let snapshot = try await ref.getDocuments()
        let ids = snapshot.documents.map { $0.documentID }
        await MainActor.run {
            self.blockUserIds = ids
        }
    }
    
    func loadBlockedByUserIds() async throws {
        guard let currentUserIds = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(currentUserIds).collection("blockedBy")
        
        let snapshot = try await ref.getDocuments()
        let ids = snapshot.documents.map { $0.documentID }
        await MainActor.run {
            self.blockedByUserIds = ids
        }
        
    }

    func loadAllBlockData() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadBlockUserIds()
            }
            group.addTask {
                try await self.loadBlockedByUserIds()
            }
            // すべてのタスクの完了を待機
            try await group.waitForAll()
        }
    }
    
    /// ブロックユーザーのフィルタリング関数
    func filterBlockedUsers<T: UserIdentifiable>(dataList: [T]) -> [T] {
        return dataList.filter { historyData in
            !BlockUserManager.shared.blockUserIds.contains(historyData.userIdentifier) &&
            !BlockUserManager.shared.blockedByUserIds.contains(historyData.userIdentifier)
        }
    }

    /// ブロックされたユーザーであるか確認
    func isUserBlocked(id: String) -> Bool {
        return blockUserIds.contains(id) || blockedByUserIds.contains(id)
    }
}
