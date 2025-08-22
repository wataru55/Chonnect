//
//  FollowerViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/13.
//

import Foundation
import Combine
import Firebase

class FollowerViewModel: ObservableObject {
    @Published var followers: [UserDatePair] = []
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    private var userProvider: UserProvider?

    init() {
        listenForUpdates()
        setupSubscribers()

        Task {
            self.userProvider = try? await UserProvider()
            await loadFollowers()
        }
    }

    @MainActor
    func loadFollowers() async {
        guard let provider = self.userProvider else {
            print("UserProviderが準備できていません。")
            return
        }
        
        do {
            let followersData = try await FollowService.fetchFollowers(receivedId: "")
            let users = try await provider.fetchUsers(with: followersData)
            
            let userDictionary = users.reduce(into: [String: User]()) { $0[$1.id] = $1 }
            self.followers = followersData.compactMap { data in
                if let user = userDictionary[data.userId] {
                    return UserDatePair(user: user, date: data.date)
                }
                return nil
            }
        } catch {
            print("Error fetching followers: \(error)")
        }
    }

    func listenForUpdates() {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        listener = Firestore.firestore().collection("users").document(documentId).collection("followers")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for updates: \(error)")
                    return
                }
                guard let _ = querySnapshot else {
                    print("QuerySnapshot data was empty.")
                    return
                }
                Task {
                    await self.loadFollowers()
                }
            }
    }
    
    private func setupSubscribers() {
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] blockUserIds in
                guard let self = self else { return }
                
                // blockUserIdsに含まれるユーザーを除外
                self.followers = self.followers.filter { follower in
                    !blockUserIds.contains(follower.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        listener?.remove()
    }
}
