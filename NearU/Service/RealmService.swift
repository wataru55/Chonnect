//
//  RealmService.swift
//  NearU
//
//  Created by 高橋和 on 2025/01/25.
//

import SwiftUI
import RealmSwift

actor RealmService {
    var realm: Realm!
    
    init() async throws {
        realm = try await Realm(actor: self)
    }
    
    func saveHistoryData(userId: String, date: Date) async {
        do {
            try await realm.asyncWrite {
                if let existingData = realm.objects(HistoryData.self).filter("userId == %@", userId).first {
                    existingData.date = date
                } else {
                    let newData = HistoryData()
                    newData.userId = userId
                    newData.date = date
                    realm.add(newData)
                }
            }
        } catch {
            print("Error saving or updating history data in Realm: \(error)")
        }
    }
    
    func fetchAllHistoryData() -> [HistoryDataStruct] {
        let data = realm.objects(HistoryData.self)
        let historyDataStruct = Array(data.map { HistoryDataStruct(from: $0) })
        return historyDataStruct
    }
    
    func deleteHistoryData(for userIds: [String]) async {
        do {
            try await realm.asyncWrite {
                let objectsToDelete = realm.objects(HistoryData.self).filter("userId IN %@", userIds)
                realm.delete(objectsToDelete)
            }
        } catch {
            print("Error deleting history data: \(error)")
        }
    }
}


