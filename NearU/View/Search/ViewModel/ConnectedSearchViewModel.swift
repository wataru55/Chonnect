//
//  ConnectedSearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/03.
//

import Foundation

class ConnectedSearchViewModel: ObservableObject {
    let currentUser: User
    @Published var ConnectedUsers = [User]() //User型の空の配列を作成

    init(currentUser: User) {
        self.currentUser = currentUser
        Task { try await fetchConnectedUsers() }
    }

    @MainActor
    func fetchConnectedUsers() async throws {
        self.ConnectedUsers = try await UserService.fetchConnectedUsers(withUid: currentUser.id)
    }
}
