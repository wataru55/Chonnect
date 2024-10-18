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

    @Published var encountData: [EncountDataStruct] = []

    private init() {
        // 初期化時にRealmからデータを読み込む
        loadUserIdsFromRealm()
    }

    // Realmからデータを読み込む
    func loadUserIdsFromRealm() {
        do {
            let realm = try Realm()
            let results = realm.objects(EncountData.self)
            let encountDataArray = results.map { EncountDataStruct(from: $0) }
            self.encountData = Array(encountDataArray)
        } catch {
            print("Error loading Realm data: \(error)")
        }
    }

    // すれ違ったユーザーIDを保存または更新
    func storeData(_ receivedUserId: String) {
        do {
            let realm = try Realm()
            if let existingEncountData = realm.objects(EncountData.self).filter("userId == %@", receivedUserId).first {
                try realm.write {
                    existingEncountData.date = Date()
                }
                print("User ID \(receivedUserId) already exists, date updated in Realm.")
                if let index = self.encountData.firstIndex(where: { $0.userId == receivedUserId }) {
                    self.encountData[index].date = existingEncountData.date
                }
            } else {
                let newEncountData = EncountData()
                newEncountData.userId = receivedUserId
                newEncountData.date = Date()

                try realm.write {
                    realm.add(newEncountData)
                }
                print("User ID \(receivedUserId) has been stored in Realm.")

                let newEncountDataStruct = EncountDataStruct(from: newEncountData)
                self.encountData.append(newEncountDataStruct)
            }
        } catch {
            print("Error storing Realm data: \(error)")
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
                if let index = self.encountData.firstIndex(where: { $0.userId == userId }) {
                    self.encountData.remove(at: index)
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

    // RealmからEncountDataを取得する関数
    func getUserIDs() -> [EncountDataStruct] {
        return encountData
    }
}

