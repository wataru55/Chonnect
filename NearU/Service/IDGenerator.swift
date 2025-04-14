//
//  IDGenerator.swift
//  NearU
//
//  Created by 高橋和 on 2025/04/14.
//

import Foundation
import Firebase

struct IDGenerator {
    private static let idCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    static func generateUniqueUserId() async throws -> String {
        var documentId = ""
        var isUnique = false

        repeat {
            documentId = generateRandomDocumentId()
            isUnique = try await isDocumentIdUnique(documentId)
        } while !isUnique

        return documentId
    }
    
    // 8文字のランダムなdocumentIdを生成する関数
    static func generateRandomDocumentId(length: Int = 8) -> String {
        return String((0..<length).compactMap { _ in idCharacters.randomElement() })
    }
    
    static func isDocumentIdUnique(_ userId: String) async throws -> Bool {
        let query = Firestore.firestore().collection("users").whereField("userId", isEqualTo: userId).limit(to: 1)
        
        do {
            let snapshot = try await query.getDocuments()
            return snapshot.isEmpty
        } catch let error as NSError {
            switch error.code {
            case FirestoreErrorCode.unavailable.rawValue,
                FirestoreErrorCode.deadlineExceeded.rawValue:
                throw AuthError.networkError
            default:
                throw AuthError.serverError
            }
        }
    }
}
