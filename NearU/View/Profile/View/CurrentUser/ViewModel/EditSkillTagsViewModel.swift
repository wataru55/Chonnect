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
    @Published var Tags: [WordElement] = []
    @Published var skillSortedTags: [WordElement] = []
    let skillLevels = ["1", "2", "3", "4", "5"]

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribers()

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
            if !newlanguage.name.isEmpty && !Tags.contains(where: { $0.name == newlanguage.name }) {
                do {
                    try await TagsService.addTags(tagData: newlanguage)
                } catch {
                    print("DEBUG: Error adding tags \(error)")
                }
            }
        }
    }

    func updateSkillTags() async {
        for language in Tags {
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
            Tags = try await TagsService.fetchTags(documentId: documentId)
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

    func setupSubscribers() {
        $Tags
            .sink { [weak self] tags in
                guard let self = self else { return }
                self.skillSortedTags = tags.sorted { $0.skill > $1.skill }
            }
            .store(in: &cancellables)
    }

}
