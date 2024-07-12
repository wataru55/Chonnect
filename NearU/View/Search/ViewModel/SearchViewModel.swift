//
//  SearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var allUsers = [User]() // User型の空の配列を作成
    private var cancellables = Set<AnyCancellable>()

    init() {
        // UserDefaultsManager の receivedUserIds を監視
        UserDefaultsManager.shared.$userIds //Publisherにアクセス
            .sink { [weak self] userIds in //.sinkがSubscriber
                guard let self = self else { return }
                Task {
                    await self.fetchWaitingAllUsers(userIds: userIds)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func fetchWaitingAllUsers(userIds: [String]) async {
        do {
            self.allUsers = try await UserService.fetchWaitingUsers(userIds)
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}


