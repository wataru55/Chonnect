//
//  TagsService.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import SwiftUI
import Firebase

struct TagsService {

    static func addTags(tagData: WordElement) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId).collection("selectedTags")
        let id = tagData.id.uuidString

        let data: [String: String] = [
            "id": id,
            "name": tagData.name,
            "skill": tagData.skill,
            "interest": tagData.interest
        ]

        do {
            try await ref.document(id).setData(data)
        } catch {
            throw error
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
                let interest = data["interest"] as? String ?? ""

                return WordElement(id: UUID(uuidString: id) ?? UUID(), name: name, skill: skill, interest: interest)
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
        } catch {
            throw error
        }
    }
}
