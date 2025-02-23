//
//  UserActions.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.
//

import Foundation
import Firebase

struct UserActions {
    
    static func blockUser(targetUserId: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        let db = Firestore.firestore()
        
        // 自分のblocksへのパス
        let myBlockRef = db.collection("users").document(currentUserId).collection("blocks").document(targetUserId)
        // 相手のblocksへのパス
        let targetBlockRef = db.collection("users").document(targetUserId).collection("blockedBy").document(currentUserId)
        
        // バッチ処理でユーザーをブロック
        let batch = db.batch()
        batch.setData(["timeStamp": Timestamp()], forDocument: myBlockRef)
        batch.setData(["timeStamp": Timestamp()], forDocument: targetBlockRef)
        
        try await batch.commit()
    }
}
