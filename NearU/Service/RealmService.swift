//
//  RealmService.swift
//  NearU
//
//  Created by 高橋和 on 2025/01/25.
//

import SwiftUI
import RealmSwift

class RealmService {
    static let shared = RealmService()
    
    func saveHistoryData(userId: String, date: Date, isRead: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                if let existingData = realm.objects(HistoryData.self).filter("userId == %@", userId).first {
                    existingData.date = date
                } else {
                    let newData = HistoryData()
                    newData.userId = userId
                    newData.date = date
                    newData.isRead = isRead
                    realm.add(newData)
                }
            }
        } catch {
            print("Error saving or updating history data in Realm: \(error)")
        }
    }
    
    func fetchAllHistoryData() -> [HistoryDataStruct] {
        do {
            let realm = try Realm()
            let data = realm.objects(HistoryData.self)
            let historyDataStruct = Array(data.map { HistoryDataStruct(from: $0) })
            return historyDataStruct
        } catch {
            print("Error fetching history data: \(error)")
            return []
        }
    }
    
    func deleteHistoryData(for userIds: [String]) {
        do {
            let realm = try Realm()
            try realm.write {
                let objectsToDelete = realm.objects(HistoryData.self).filter("userId IN %@", userIds)
                realm.delete(objectsToDelete)
            }
        } catch {
            print("Error deleting history data: \(error)")
        }
    }
}


