//
//  EditSkillTagsViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import SwiftUI
import Firebase

class EditSkillTagsViewModel: ObservableObject {
    @Published var languages: [WordElement] = []
    let skillLevels = ["1", "2", "3", "4", "5"]
    let interestLevels = ["", "1", "2", "3", "4", "5"]

    init() {
        Task {
            await loadSkillTags()
        }
    }

    func saveSkillTags(newlanguages: [WordElement]) async {
        for newlanguage in newlanguages {
            if !newlanguage.name.isEmpty {
                do {
                    try await TagsService.addTags(tagData: newlanguage)
                } catch {
                    print("DEBUG: Error adding tags \(error)")
                }
            }
        }
    }

    @MainActor
    func loadSkillTags() async {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        do {
            languages = try await TagsService.fetchTags(documentId: documentId)
        } catch {
            print("DEBUG: Error fetching tags \(error)")
        }
    }

}
