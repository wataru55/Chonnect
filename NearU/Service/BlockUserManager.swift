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
    
    func blockUser(targetUserId: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // 自分のblocksへのパス
        let myBlockRef = db.collection("users").document(currentUserId).collection("blocks").document(targetUserId)
        // 相手のblocksへのパス
        let targetBlockRef = db.collection("users").document(targetUserId).collection("blockedBy").document(currentUserId)
        
        // バッチ処理でユーザーをブロック
        batch.setData(["timeStamp": Timestamp()], forDocument: myBlockRef)
        batch.setData(["timeStamp": Timestamp()], forDocument: targetBlockRef)
        
        do {
            try await batch.commit()
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
        
        await MainActor.run {
            blockUserIds.append(targetUserId)
        }
    }
    
    func unblockUser(targetUserId: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw FireStoreSaveError.missingUserId
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // 自分のblocksへのパス
        let myBlockRef = db.collection("users").document(currentUserId).collection("blocks").document(targetUserId)
        // 相手のblocksへのパス
        let targetBlockRef = db.collection("users").document(targetUserId).collection("blockedBy").document(currentUserId)
        
        // バッチ削除
        batch.deleteDocument(myBlockRef)
        batch.deleteDocument(targetBlockRef)
        
        do {
            try await batch.commit()
        
        } catch let error as NSError {
            throw mapFirestoreError(error)
        }
        
        await MainActor.run {
            self.blockUserIds.removeAll { $0 == targetUserId }
        }
    }
    
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

    func loadAllBlockData() async {
        do {
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
        } catch {
            print("Error loading block data: \(error.localizedDescription)")
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
    
    private func mapFirestoreError(_ error: NSError) -> FireStoreSaveError {
        switch error.code {
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .permissionDenied
        case FirestoreErrorCode.deadlineExceeded.rawValue:
            return .networkError
        case FirestoreErrorCode.unavailable.rawValue:
            return .serverError
        default:
            return .unknown(underlying: error)
        }
    }
}
