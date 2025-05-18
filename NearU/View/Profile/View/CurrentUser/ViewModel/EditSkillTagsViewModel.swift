//
//  EditSkillTagsViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import SwiftUI
import Firebase
import Combine

class EditSkillTagsViewModel: ObservableObject {
    @Published var skillSortedTags: [WordElement] = []
    @Published var languages: [WordElement] = [
        WordElement(id: UUID(), name: "", skill: "3")
    ]
    
    let skillLevels = ["1", "2", "3", "4", "5"]

    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await loadSkillTags()
        }
    }

    func saveSkillTags() async {
        let newLanguages = languages.filter { language in
            !language.name.isEmpty && !skillSortedTags.contains(where: { $0.name == language.name })
        }
        
        let mergedTags = skillSortedTags + newLanguages
        
        do {
            try await TagsService.saveTags(tagData: mergedTags)
            await MainActor.run {
                self.skillSortedTags = sortSkillTags(tags: mergedTags)
            }
        } catch {
            print("DEBUG: Error saving tags \(error)")
        }
    }

    @MainActor
    func loadSkillTags() async {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        do {
            let tags = try await TagsService.fetchTags(documentId: documentId)
            self.skillSortedTags = tags.sorted { $0.skill > $1.skill }
        } catch {
            print("DEBUG: Error fetching tags \(error)")
        }
    }

    func deleteSkillTag(id: String) async {
        do {
            try await TagsService.deleteTag(id: id)
            await MainActor.run {
                skillSortedTags.removeAll(where: { $0.id.uuidString == id })
            }
        } catch {
            print("DEBUG: Error deleting tag \(error)")
        }
    }
    
    func sortSkillTags(tags: [WordElement]) -> [WordElement] {
        return tags.sorted { $0.skill > $1.skill }
    }

}
