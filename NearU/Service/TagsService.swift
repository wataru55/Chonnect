//
//  TagsService.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import SwiftUI
import Firebase

struct TagsService {

    static func saveTags(tagData: [WordElement]) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }

        let batch = Firestore.firestore().batch()
        let ref = Firestore.firestore().collection("users").document(documentId).collection("selectedTags")
        
        for tag in tagData {
            let docRef = ref.document(tag.id.uuidString)
            let data: [String: String] = [
                "id": tag.id.uuidString,
                "name": tag.name,
                "skill": tag.skill,
            ]
            batch.setData(data, forDocument: docRef)
        }

        do {
            try await batch.commit()
        } catch let error as NSError {
            switch error.code {
            case FirestoreErrorCode.permissionDenied.rawValue:
                throw FireStoreSaveError.permissionDenied
            case FirestoreErrorCode.deadlineExceeded.rawValue:
                throw FireStoreSaveError.networkError
            case FirestoreErrorCode.unavailable.rawValue:
                throw FireStoreSaveError.serverError
            default:
                throw FireStoreSaveError.unknown(underlying: error)
            }
        }
    }

    static func fetchTags(documentId: String) async throws -> [WordElement] {
        let ref = Firestore.firestore().collection("users").document(documentId).collection("selectedTags")

        do {
            let snapshot = try await ref.getDocuments()
            let tags = snapshot.documents.compactMap { document -> WordElement? in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let skill = data["skill"] as? String ?? ""

                return WordElement(id: UUID(uuidString: id) ?? UUID(), name: name, skill: skill)
            }
            return tags
        } catch {
            throw error
        }
    }

    static func deleteTag(id: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId).collection("selectedTags")

        do {
            try await ref.document(id).delete()
        } catch let error as NSError {
            switch error.code {
            case FirestoreErrorCode.permissionDenied.rawValue:
                throw FireStoreSaveError.permissionDenied
            case FirestoreErrorCode.deadlineExceeded.rawValue:
                throw FireStoreSaveError.networkError
            case FirestoreErrorCode.unavailable.rawValue:
                throw FireStoreSaveError.serverError
            default:
                throw FireStoreSaveError.unknown(underlying: error)
            }
        }
    }
}
