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
    @Published var userDatePairs = [UserDatePair]()
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
            // ユーザーと日付を UserDatePair に変換
            self.userDatePairs = zip(users, dates).map { UserDatePair(user: $0, date: $1) }
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}




