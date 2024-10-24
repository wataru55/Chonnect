//
//  ProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/15.
//

import Foundation
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var currentUser: User
    @Published var abstractLinks: [String: String] = [:]

    init(user: User, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
    }

    @MainActor
    func loadUserData() async {
        do {
            let userSnapshot = try await Firestore.firestore().collection("users").document(user.id).getDocument()
            if let fetchedUser = try? userSnapshot.data(as: User.self) {
                self.user = fetchedUser
            }

            let currentUserSnapshot = try await Firestore.firestore().collection("users").document(currentUser.id).getDocument()
            if let fetchedCurrentUser = try? currentUserSnapshot.data(as: User.self) {
                self.currentUser = fetchedCurrentUser
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
        }
    }
    
    func fetchAbstractLinks() {
            Firestore.firestore()
                .collection("users")
                .document(user.id)
                .collection("abstract")
                .getDocuments { [weak self] (snapshot, error) in
                    if let error = error {
                        print("Error fetching abstract links: \(error)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    // フェッチしたデータを辞書に保存
                    var fetchedLinks: [String: String] = [:]
                    
                    for document in documents {
                        if let title = document.data()["abstract_title"] as? String,
                           let url = document.data()["abstract_url"] as? String {
                            fetchedLinks[title] = url
                        }
                    }
                    print("Fetched abstract links:", fetchedLinks)
                    DispatchQueue.main.async {
                        self?.abstractLinks = fetchedLinks
                    }
                }
        }
}
