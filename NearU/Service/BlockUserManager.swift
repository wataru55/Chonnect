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
    
    static let shared = BlockUserManager()
    
    private init() {
        Task {
            try await loadBlockUserIds()
        }
    }
    
    /// ブロックした全ユーザーのidをフェッチ
    func loadBlockUserIds() async throws {
        guard let currentUserIds = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(currentUserIds).collection("blocks")
        
        do {
            let snapshot = try await ref.getDocuments()
            let ids = snapshot.documents.map { $0.documentID }
            await MainActor.run {
                self.blockUserIds = ids
            }
        } catch {
            throw error
        }
    }
    
    /// ブロックされたユーザーであるか確認
    func isUserBlocked(id: String) -> Bool {
        return blockUserIds.contains(id)
    }
}
