//
//  EditSkillTagsViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import Combine
import Firebase
import SwiftUI

class EditSkillTagsViewModel: ObservableObject {
    @Published var skillSortedTags: [WordElement] = []
    @Published var languages: [WordElement] = [
        WordElement(id: UUID(), name: "", skill: "3")
    ]
    @Published var state: ViewState = .idle
    @Published var isShowAlert: Bool = false
    @Published var errorMessage: String?

    private weak var currentUserProfileViewModel: CurrentUserProfileViewModel?
    private var cancellables = Set<AnyCancellable>()
    private var skillTagsCancellable: AnyCancellable?
    let skillLevels = ["1", "2", "3", "4", "5"]

    var mergedTags: [WordElement] {
        let newLanguages = languages.filter { language in
            !language.name.isEmpty && !skillSortedTags.contains(where: { $0.name == language.name })
        }

        return skillSortedTags + newLanguages
    }

    var isAbleToSave: Bool {
        return currentUserProfileViewModel?.skillSortedTags != mergedTags
    }

    // CurrentUserProfileViewModelを設定するメソッド
    func setCurrentUserProfileViewModel(_ viewModel: CurrentUserProfileViewModel) {
        self.currentUserProfileViewModel = viewModel

        skillTagsCancellable?.cancel()

        skillTagsCancellable = viewModel.$skillSortedTags
            .sink { [weak self] tags in
                guard let self = self else { return }
                self.skillSortedTags = sortSkillTags(tags: tags)
            }
    }

    @MainActor
    func saveSkillTags() async {
        state = .loading

        do {
            try await TagsService.saveTags(tagData: mergedTags)
            currentUserProfileViewModel?.skillSortedTags = mergedTags
            await currentUserProfileViewModel?.updateCache()
            self.languages = [WordElement(id: UUID(), name: "", skill: "3")]
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

    @MainActor
    func deleteSkillTag(id: String) async {
        state = .loading

        do {
            try await TagsService.deleteTag(id: id)
            currentUserProfileViewModel?.skillSortedTags.removeAll(
                where: { $0.id.uuidString == id }
            )
            await currentUserProfileViewModel?.updateCache()
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

    func reset() {
        self.languages = [WordElement(id: UUID(), name: "", skill: "3")]
        self.skillSortedTags = currentUserProfileViewModel?.skillSortedTags ?? []
    }

    deinit {
        skillTagsCancellable?.cancel()
    }

}
