//
//  RealmManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/10.
//

import SwiftUI
import RealmSwift
import FirebaseFirestore

@MainActor
class RealmManager: ObservableObject {
    static let shared = RealmManager()

    @Published var historyData: [HistoryDataStruct] = []
    @Published var realtimeData: [EncountDataStruct] = []

    private init() {
        // 初期化時にRealmからデータを読み込む
        loadHistoryDataFromRealm()
        loadRealtimeDataFromRealm()
    }

    // Realmからデータを読み込む
    func loadHistoryDataFromRealm() {
        do {
            // Realmのインスタンスを生成
            let realm = try Realm()
            // RealmからHistoryDataオブジェクトの全てのデータを取得
            let results = realm.objects(HistoryData.self)
            // HistoryDataオブジェクトをHistoryDataStructに変換して配列に格納
            let historyDataArray = results.map { HistoryDataStruct(from: $0) }
            self.historyData = Array(historyDataArray)
        } catch {
            print("Error loading Realm data: \(error)")
        }
    }

    // Realmからリアルタイムデータを読み込む
    func loadRealtimeDataFromRealm() {
        do {
            // Realmのインスタンスを生成
            let realm = try Realm()
            // RealmからEncountDataオブジェクトの全てのデータを取得
            let results = realm.objects(EncountData.self)
            // EncountDataオブジェクトをEncountDataStructに変換して配列に格納
            let encountDataArray = results.map { EncountDataStruct(from: $0) }
            self.realtimeData = Array(encountDataArray)
        } catch {
            print("Error loading Realm data: \(error)")
        }
    }

    // すれ違ったユーザーIDと日付を履歴に保存または更新
    func storeData(_ receivedUserId: String, date: Date) {
        do {
            let realm = try Realm()
            // 既存のユーザーIDがRealmにあるか確認
            if let existingHistoryData = realm.objects(HistoryData.self).filter("userId == %@", receivedUserId).first {
                // 既存データがあれば、日付を更新
                try realm.write {
                    existingHistoryData.date = date
                }
                print("User ID \(receivedUserId) already exists, date updated in Realm.")
                // メモリ上のencountData配列も更新
                if let index = self.historyData.firstIndex(where: { $0.userId == receivedUserId }) {
                    self.historyData[index].date = existingHistoryData.date
                }
            } else {
                // 新規データの作成
                let newHistoryData = HistoryData()
                newHistoryData.userId = receivedUserId
                newHistoryData.date = date
                newHistoryData.isRead = false

                // Realmに保存
                try realm.write {
                    realm.add(newHistoryData)
                }
                print("User ID \(receivedUserId) has been stored in Realm.")
                // メモリ上の配列に追加
                let newHistoryDataStruct = HistoryDataStruct(from: newHistoryData)
                self.historyData.append(newHistoryDataStruct)
            }
        } catch {
            print("Error storing Realm data: \(error)")
        }
    }

    // すれ違ったユーザーIDと日付をリアルタイム用のデータに保存または更新
    func storeRealtimeData (receivedUserId: String, date: Date, rssi: Int) {
        do {
            let realm = try Realm()
            // 既存のユーザーIDがRealmにあるか確認
            if let existingRealtimeData = realm.objects(EncountData.self).filter("userId == %@", receivedUserId).first {
                // 既存データがあれば、日付を更新
                try realm.write {
                    existingRealtimeData.date = date
                    existingRealtimeData.rssi = rssi
                }
                print("User ID \(receivedUserId) already exists, rssiupdated in Realm.")
                // メモリ上のencountData配列も更新
                if let index = self.realtimeData.firstIndex(where: { $0.userId == receivedUserId }) {
                    self.realtimeData[index].date = existingRealtimeData.date
                    self.realtimeData[index].rssi = existingRealtimeData.rssi
                }
            } else {
                // 新規データの作成
                let newRealtimeData = EncountData()
                newRealtimeData.userId = receivedUserId
                newRealtimeData.date = date
                newRealtimeData.rssi = rssi

                // Realmに保存
                try realm.write {
                    realm.add(newRealtimeData)
                }
                print("User ID \(receivedUserId) has been stored in Realm.")
                // メモリ上の配列に追加
                let newRealtimeDataStruct = EncountDataStruct(from: newRealtimeData)
                self.realtimeData.append(newRealtimeDataStruct)
            }
        } catch {
            print("Error storing Realm data: \(error)")
        }
    }

    // 既読情報を更新するメソッド
    func updateRead(_ receivedUserId: String) {
        do {
            let realm = try Realm()
            // 既存のユーザーIDがRealmにあるか確認
            guard let existingHistoryData = realm.objects(HistoryData.self).filter("userId == %@", receivedUserId).first else { return }

            // 既読情報を更新
            try realm.write {
                existingHistoryData.isRead = true
            }
            // メモリ上のhistoryData配列も更新
            // indexを取得
            guard let index = self.historyData.firstIndex(where: { $0.userId == receivedUserId }) else { return }
            // 更新
            self.historyData[index].isRead = existingHistoryData.isRead
        } catch {
            print("Error updating isRead data: \(error)")
        }
    }

    func removeData(_ userId: String) {
        do {
            let realm = try Realm()

            // 該当するデータを検索
            if let existingEncountData = realm.objects(EncountData.self).filter("userId == %@", userId).first {
                try realm.write {
                    // Realmからデータを削除
                    realm.delete(existingEncountData)
                }
                print("User ID \(userId) has been removed from Realm.")

                // `encountData`リストからも削除
                if let index = self.historyData.firstIndex(where: { $0.userId == userId }) {
                    self.historyData.remove(at: index)
                    print("encountData removed for userId: \(userId)")
                }
            }

            // Realmに残っているデータの一覧を表示
            let allEncountData = realm.objects(EncountData.self)
            print("Current Realm data after deletion:")
            for data in allEncountData {
                print(data) // `EncountData`の各プロパティを表示する
            }

        } catch {
            print("Error removing Realm data: \(error)")
        }
    }

    // 古いリアルタイムデータを削除するメソッド
    func removeRealtimeData(interval: TimeInterval = 5.0) {
        do {
            let realm = try Realm()
            let removeDate = Date().addingTimeInterval(-interval)
            let outdatedUsers = realm.objects(EncountData.self).filter("date < %@", removeDate)

            if !outdatedUsers.isEmpty {
                try realm.write {
                    realm.delete(outdatedUsers)
                }
                print("Deleted \(outdatedUsers.count) outdated users from Realm.")
                // メモリ上のrealtimeData配列からも削除
                let outdatedUserIds = outdatedUsers.map { $0.userId }
                realtimeData.removeAll { outdatedUserIds.contains($0.userId) }
            }
        } catch {
            print("Error during cleanup: \(error)")
        }
    }

}

