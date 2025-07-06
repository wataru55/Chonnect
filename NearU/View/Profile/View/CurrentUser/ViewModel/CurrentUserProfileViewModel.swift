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
    @Published var userName: String = ""
    @Published var bio: String = ""
    
    @Published var isLoading: Bool = false
    @Published var state: ViewState = .idle
    @Published var alertType: AlertType? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    var isUsernameValid: Bool {
        Validation.validateUsername(username: userName)
    }
    
    var isUsernameUnique: Bool {
        //　変更前と変更後のユーザーネームが同じでない
        user.username != userName
    }
    
    var isBioValid: Bool {
        bio.count <= 100
    }
    
    var isBioUnique: Bool {
        user.bio != bio
    }
    
    var isInterestedTagValid: Bool {
        Validation.validateInterestTag(tags: user.interestTags)
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
    
    @MainActor
    func saveUserName() async throws {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        
        do {
            try await CurrentUserService.updateUserName(username: userName)
            AuthService.shared.currentUser?.username = userName
            self.state = .success
            
        } catch {
            self.alertType = .okOnly(message: error.localizedDescription)
            throw error
        }
    }
    
    @MainActor
    func saveBio() async throws {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        
        // 空白行削除
        let cleanedBio = bio.removingBlankLines()
        
        do {
            try await CurrentUserService.updateBio(bio: cleanedBio)
            AuthService.shared.currentUser?.bio = cleanedBio
            self.state = .success
            
        } catch {
            self.alertType = .okOnly(message: error.localizedDescription)
            throw error
        }
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

extension String {
    func removingBlankLines() -> String {
        self
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }
}
