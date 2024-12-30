//
//  BLERealtimeViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/06.
//

import SwiftUI
import Combine

@MainActor
class BLERealtimeViewModel: ObservableObject {
    @Published var userRealtimeRecords: [UserRealtimeRecord] = []
    @Published var sortedUserRealtimeRecords: [UserRealtimeRecord] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task {
            await fetchRealtimeAllUsers(realtimeDataList: RealmRealtimeManager.shared.realtimeData)
        }
        setupSubscribers()
    }

    @MainActor
    func fetchRealtimeAllUsers(realtimeDataList: [EncountDataStruct]) async {
        do {
            var addData: [UserRealtimeRecord] = []

            for data in realtimeDataList {
                let user = try await UserService.fetchUser(withUid: data.userId)
                let interestTags = try await UserService.fetchInterestTags(documentId: data.userId)

                addData.append(UserRealtimeRecord(user: user, tags: interestTags, date: data.date, rssi: data.rssi))
            }

            self.userRealtimeRecords = addData

        } catch {
            print("Error fetching users: \(error)")
        }
    }

    func setupSubscribers() {
        RealmRealtimeManager.shared.$realtimeData
            .sink { [weak self] realtimeDataList in
                guard let self = self else { return }
                Task {
                    await self.fetchRealtimeAllUsers(realtimeDataList: realtimeDataList)
                }
            }
            .store(in: &cancellables)

        $userRealtimeRecords
            .map { records in
                records.sorted { $0.rssi > $1.rssi }
            }
            .assign(to: &$sortedUserRealtimeRecords)
    }

}
