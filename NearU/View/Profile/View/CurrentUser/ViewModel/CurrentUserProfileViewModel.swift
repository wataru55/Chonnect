//
//  EditProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import PhotosUI
import SwiftUI
import Firebase
import Combine

class CurrentUserProfileViewModel: ObservableObject {
    @Published var user: User

    private var cancellables = Set<AnyCancellable>()
    
    var isUsernameValid: Bool {
        Validation.validateUsername(username: user.username)
    }
    
    var isNotOverCharacterLimit: Bool {
        Validation.validateBio(bio: user.bio ?? "")
    }
    
    var isInterestedTagValid: Bool {
        Validation.validateInterestTag(tags: user.interestTags)
    }
    
    var isAbleToSave: Bool {
        isUsernameValid && isNotOverCharacterLimit && isInterestedTagValid
    }

    init() {
        if let currentUser = AuthService.shared.currentUser {
            self.user = currentUser
        } else {
            self.user = User(id: "", uid: "", username: "", isPrivate: false, snsLinks: [:], interestTags: [])
        }

        setupSubscribers()
    }

    func setupSubscribers() {
        // currentUserプロパティが変更されるとクロージャが実行される
        AuthService.shared.$currentUser
            .compactMap({ $0 })
            .sink { [weak self] currentUser in
                self?.user = currentUser
            }
            .store(in: &cancellables)
    }

    func updateUserData(addTags: [String] = []) async {
        let filteredTags = addTags.filter { !$0.isEmpty }
        
        do {
            try await CurrentUserService.updateUserProfile(username: user.username, bio: user.bio ?? "", interestTags: filteredTags)
            let result = await CurrentUserService.loadCurrentUser()
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } catch {
            print("Error updating user data: \(error)")
        }
    }
    
    @MainActor
    func deleteTag(tag: String) {
        user.interestTags.removeAll { $0 == tag }
    }
}
