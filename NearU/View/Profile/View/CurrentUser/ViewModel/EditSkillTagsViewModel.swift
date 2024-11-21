//
//  EditSkillTagsViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/21.
//

import SwiftUI
import Firebase

class EditSkillTagsViewModel: ObservableObject {
    @Published var languages: [WordElement] = [
        WordElement(id: UUID(), name: "", skill: "3", interest: "")
    ]
    let skillLevels = ["1", "2", "3", "4", "5"]
    let interestLevels = ["", "1", "2", "3", "4", "5"]

    func saveSkillTags() async {
        for language in languages {
            if !language.name.isEmpty {
                do {
                    try await TagsService.addTags(tagData: language)
                } catch {
                    print("DEBUG: Error adding tags \(error)")
                }
            }
        }
    }

}
