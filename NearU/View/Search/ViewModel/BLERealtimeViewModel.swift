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
            await fetchRealtimeAllUsers(realtimeDataList: RealtimeDataManager.shared.realtimeData)
        }
        setupSubscribers()
    }

    @MainActor
    func fetchRealtimeAllUsers(realtimeDataList: [EncountDataStruct]) async {
        do {
            var addData: [UserRealtimeRecord] = []

            for data in realtimeDataList {
                let user = try await UserService.fetchUser(withUid: data.userId)

                addData.append(UserRealtimeRecord(user: user, date: data.date, rssi: data.rssi))
            }

            self.userRealtimeRecords = addData

        } catch {
            print("Error fetching users: \(error)")
        }
    }

    func setupSubscribers() {
        RealtimeDataManager.shared.$realtimeData
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
        
        BlockUserManager.shared.$blockUserIds
            .sink { [weak self] newBlockUserIds in
                guard let self = self else { return }
                
                self.userRealtimeRecords = self.userRealtimeRecords.filter { record in
                    !newBlockUserIds.contains(record.user.userIdentifier)
                }
            }
            .store(in: &cancellables)
    }

}
