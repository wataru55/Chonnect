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
}
