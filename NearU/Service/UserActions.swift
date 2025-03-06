//
//  UserActions.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.
//

import Foundation
import Firebase

struct UserActions {
    
    static func report(to: String, content: String) async throws {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        let reportRef = Firestore.firestore().collection("reports").document("\(currentUserId)_\(to)")
            
        let data: [String: Any] = [
            "from": currentUserId,
            "to": to,
            "content": content,
            "timeStamp": Timestamp()
        ]
        
        try await reportRef.setData(data)
    }
}
