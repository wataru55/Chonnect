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
    
    static func fetchHistoryUser() async throws -> [HistoryDataStruct] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        
        let path = Firestore.firestore().collection("users").document(documentId).collection("history")
        let snapshot = try await path.getDocuments()
        
        var historyData: [HistoryDataStruct] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: HistoryDataStruct.self)
            historyData.append(data)
        }
        
        return historyData
    }
    
    static func changeIsRead(userId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let path = Firestore.firestore().collection("users").document(documentId).collection("history").document(userId)
        
        try await path.updateData(["isRead" : true])
    }
}
