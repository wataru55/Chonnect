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
class RealmHistoryManager: ObservableObject {
    static let shared = RealmHistoryManager()

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

    init() {
        // --- 10秒おきのバッチ処理 (Realm書き込み) ---
        historyBatchTimer = Timer.scheduledTimer(withTimeInterval: historyBatchInterval,
                                                 repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.saveHistoryDataToRealm()  // 10秒に1回、メモリ→Realm
            }
        }
        
        // --- 30秒おきのFirestore同期＆Realm削除 ---
        firestoreSyncTimer = Timer.scheduledTimer(withTimeInterval: firestoreSyncInterval,
                                                  repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.syncHistoryDataToFireStore()  // 30秒に1回、Realm→Firestore→削除
            }
        }
    }
    
    deinit {
        historyBatchTimer?.invalidate()
        firestoreSyncTimer?.invalidate()
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
        print("--------------saveHistoryDataToRealm------------------")
        guard !pendingHistoryData.isEmpty else {
            print("No pendingHistoryData")
            return
        }
        
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
                        newHistoryData.isRead = isRead
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
        print("--------------syncHistoryDataToFireStore------------------")
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
            // まだテストできてない
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

}

