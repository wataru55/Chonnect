//
//  SearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var users = [User]() //User型の空の配列を作成

    init() {
        Task { try await fetchAllUsers() }
    }

    @MainActor
    func fetchAllUsers() async throws {
        self.users = try await UserService.fetchAllUsers()
    }
}
