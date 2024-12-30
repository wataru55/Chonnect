//
//  RealmManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/10.
//

import SwiftUI
import RealmSwift
import FirebaseFirestore
import Combine

@MainActor
class RealmManager: ObservableObject {
    static let shared = RealmManager()

    @Published var historyData: [HistoryDataStruct] = []

    private var pendingHistoryData: [(userId: String, date: Date, isRead: Bool)] = []
    // 10秒ごとにpendingHistoryDataを Realm に書き込むタイマー
    private var historyBatchTimer: Timer?
    // 30秒ごとに Realm → Firestore → Realm削除するタイマー
    private var firestoreSyncTimer: Timer?
    
    /// 10秒に一度履歴をバッチ書き込み
    private let historyBatchInterval: TimeInterval = 10.0
    /// 30秒に一度 Firestore 同期＆削除
    private let firestoreSyncInterval: TimeInterval = 30.0
    
    private var cancellables = Set<AnyCancellable>()

    // 初回更新フラグ
    private var shouldImmediatelyUpdateHistory = true

    private init() {
        // 初期化時にRealmからデータを読み込む
        loadHistoryDataFromRealm()
    }

    // Realmから履歴データを読み込む
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

    // BLE通信でデータを受信したら呼ばれるメソッド
    func storeHistoryData(_ receivedUserId: String, date: Date) {
        // pendingに同じIdのデータがあれば更新し、なければ追加
        if let index = pendingHistoryData.firstIndex(where: {$0.userId == receivedUserId}) {
            // dateが同じ場合の処理
            if pendingHistoryData[index].date == date {
                return
            }
            
            //更新
            pendingHistoryData[index] = (receivedUserId, date, false)
        } else {
            pendingHistoryData.append((receivedUserId, date, false))
        }
    }

    // pendingHistoryDataをRealmに書き込むメソッド
    private func saveHistoryDataToRealm() {
        guard !pendingHistoryData.isEmpty else { return }
        
        let updatesToProcess = pendingHistoryData
        pendingHistoryData.removeAll()
        historyBatchTimer = nil

        do {
            let realm = try Realm()
            try realm.write {
                for (userId, date, isRead) in updatesToProcess {
                    // Realmに同じIdのデータがあればdateを更新し、なければ追加
                    if let existingHistoryData = realm.objects(HistoryData.self).filter("userId == %@", userId).first {
                        existingHistoryData.date = date
                    } else {
                        let newHistoryData = HistoryData()
                        newHistoryData.userId = userId
                        newHistoryData.date = date
                        newHistoryData.isRead = false
                        realm.add(newHistoryData)
                    }
                }
            }
            print("Processed \(updatesToProcess.count) history updates in Realm.")
        } catch {
            print("Error processing history updates: \(error)")
        }
    }
    
    // Realm上の履歴データをFirestoreに保存し、成功したものをRealmから削除するメソッド
    private func syncHistoryDataToFireStore() {
        do {
            let realm = try Realm()
            let allHistoryData = realm.objects(HistoryData.self)
            
            guard !allHistoryData.isEmpty else {
                print("No HistoryData to sync.")
                return
            }
            
            var deleteUserIds: [String] = []
            
            for historyData in allHistoryData {
                let structHistoryData = HistoryDataStruct(from: historyData)
                Task {
                    do {
                        // Firestoreに保存
                        try await HistoryService.saveHistoryUser(historyData: structHistoryData)
                        deleteUserIds.append(structHistoryData.userId)
                    } catch {
                        print("Failed to save userId \(structHistoryData.userId): \(error)")
                    }
                }
            }
            
            if !deleteUserIds.isEmpty {
                do {
                    try realm.write {
                        let objectsToDelete = realm.objects(HistoryData.self).filter("userId IN %@", deleteUserIds)
                        realm.delete(objectsToDelete)
                    }
                    print("Successfully synced & removed \(deleteUserIds.count) HistoryData from Realm.")
                } catch {
                    print("Error removing synced data from Realm: \(error)")
                }
            } else {
                print("No HistoryData was successfully synced this time.")
            }
            
        } catch {
            print("Error reading HistoryData from Realm for syncing: \(error)")
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

}

