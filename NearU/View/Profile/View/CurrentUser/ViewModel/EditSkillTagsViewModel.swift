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
    @Published var state: ViewState = .idle
    @Published var isShowAlert: Bool = false
    @Published var errorMessage: String?
    
    let skillLevels = ["1", "2", "3", "4", "5"]
    
    var mergedTags: [WordElement] {
        let newLanguages = languages.filter { language in
            !language.name.isEmpty && !skillSortedTags.contains(where: { $0.name == language.name })
        }
        
        return skillSortedTags + newLanguages
    }
        

    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await loadSkillTags()
        }
    }

    @MainActor
    func saveSkillTags() async {
        state = .loading
        
        do {
            try await TagsService.saveTags(tagData: mergedTags)
            self.skillSortedTags = sortSkillTags(tags: mergedTags)
            languages = [WordElement(id: UUID(), name: "", skill: "3")]
            state = .success
            
        } catch let error as FireStoreSaveError{
            self.isShowAlert = true
            self.errorMessage = error.localizedDescription
            state = .idle

        } catch {
            self.isShowAlert = true
            self.errorMessage = "予期せぬエラーが発生しました"
            state = .idle
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

    @MainActor
    func deleteSkillTag(id: String) async {
        state = .loading
        
        do {
            try await TagsService.deleteTag(id: id)
            skillSortedTags.removeAll(where: { $0.id.uuidString == id })
            state = .success
            
        } catch let error as FireStoreSaveError {
            self.isShowAlert = true
            self.errorMessage = error.localizedDescription
            state = .idle
        } catch {
            self.isShowAlert = true
            self.errorMessage = "予期せぬエラーが発生しました"
            state = .idle
        }
    }
    
    func sortSkillTags(tags: [WordElement]) -> [WordElement] {
        return tags.sorted { $0.skill > $1.skill }
    }

}
