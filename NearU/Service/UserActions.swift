//
//  UserActions.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.
//

import Foundation
import Firebase

struct UserActions {
    
    static func blockUser(blockUserId: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(currentUserId).collection("blocks")
        
        let addData: [String: Any] = [
            "id": blockUserId,
            "timeStamp": FieldValue.serverTimestamp()
        ]
        
        do {
            try await ref.document(blockUserId).setData(addData)
        } catch {
            throw error
        }
    }
}
