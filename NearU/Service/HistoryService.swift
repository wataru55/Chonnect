//
//  HistoryService.swift
//  NearU
//
//  Created by 高橋和 on 2024/12/27.
//

import Foundation
import Firebase

struct HistoryService {
    static func saveHistoryUser(historyData: HistoryDataStruct) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let path = Firestore.firestore().collection("users").document(documentId).collection("history")
        
        let addData: [String: Any] = [
            "userId": historyData.userId,
            "date": historyData.date,
            "isRead": historyData.isRead
        ]
        
        do {
            try await path.document(historyData.userId).setData(addData)
        } catch {
            throw error
        }
            
    }
}
