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
        await addSkillTags(newlanguages: newlanguages)
        await updateSkillTags()
        await loadSkillTags()
    }

    func addSkillTags(newlanguages: [WordElement]) async {
        for newlanguage in newlanguages {
            if !newlanguage.name.isEmpty && !languages.contains(where: { $0.name == newlanguage.name }) {
                do {
                    try await TagsService.addTags(tagData: newlanguage)
                } catch {
                    print("DEBUG: Error adding tags \(error)")
                }
            }
        }
    }

    func updateSkillTags() async {
        for language in languages {
            do {
                try await TagsService.updateTags(tagData: language)
            } catch {
                print("DEBUG: Error updating tags \(error)")
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

    func deleteSkillTag(id: String) async {
        do {
            try await TagsService.deleteTag(id: id)
            await loadSkillTags()
        } catch {
            print("DEBUG: Error deleting tag \(error)")
        }
    }

}
