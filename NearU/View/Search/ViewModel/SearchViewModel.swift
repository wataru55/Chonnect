//
//  SearchViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/18.
//
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var userDatePairs = [(User, Date)]()
    private var cancellables = Set<AnyCancellable>()

    init() {
        RealmManager.shared.$encountData
            .sink { [weak self] encountDataList in
                guard let self = self else { return }
                Task {
                    await self.fetchWaitingAllUsers(encountDataList: encountDataList)
                }
            }
            .store(in: &cancellables)
    }

    func fetchWaitingAllUsers(encountDataList: [EncountDataStruct]) async {
        do {
            let userIds = encountDataList.map { $0.userId }
            let dates = encountDataList.map { $0.date }
            let users = try await UserService.fetchWaitingUsers(userIds)
            self.userDatePairs = Array(zip(users, dates))
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}




