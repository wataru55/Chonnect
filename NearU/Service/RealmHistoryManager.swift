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
    
    private var isInForeground: Bool {
        return UIApplication.shared.applicationState == .active
    }

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
                await self?.syncHistoryDataToFireStore()  // 30秒に1回、Realm→Firestore→削除
            }
        }
    }
    
    deinit {
        historyBatchTimer?.invalidate()
        firestoreSyncTimer?.invalidate()
    }

    // BLE通信でデータを受信したら呼ばれるメソッド
    func storeHistoryData(_ receivedUserId: String, date: Date) {
        // フォアグラウンドならバッチ処理のためにメモリに保存
        if isInForeground {
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
        } else {
            //バックグラウンドならそのままRealmに書き込み
            do {
                let realm = try Realm()
                try realm.write {
                    // Realmに同じIdのデータがあればdateを更新し、なければ追加
                    if let existingHistoryData = realm.objects(HistoryData.self).filter("userId == %@", receivedUserId).first {
                        existingHistoryData.date = date
                    } else {
                        let newHistoryData = HistoryData()
                        newHistoryData.userId = receivedUserId
                        newHistoryData.date = date
                        newHistoryData.isRead = false
                        realm.add(newHistoryData)
                    }
                }
            } catch {
                print("can not save history data to realm: \(error)")
            }
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
    private func syncHistoryDataToFireStore() async {
        print("--------------syncHistoryDataToFireStore------------------")
        do {
            let realm = try await Realm()
            let allHistoryData = realm.objects(HistoryData.self)
            
            guard !allHistoryData.isEmpty else {
                print("No HistoryData to sync.")
                return
            }
            
            let historyDataList = Array(allHistoryData.map { HistoryDataStruct(from: $0) })
            
            var deleteUserIds: [String] = []
            
            // ☆ for文で逐次 await しながら Firestore に保存
            for structHistoryData in historyDataList {
                do {
                    // Firestore への保存を待機
                    print("---------------savetoFireStore------------------")
                    try await HistoryService.saveHistoryUser(historyData: structHistoryData)
                    
                    print("---------------addToDeleteUserIds------------------")
                    deleteUserIds.append(structHistoryData.userId)
                } catch {
                    print("Failed to save userId \(structHistoryData.userId): \(error)")
                }
            }

            // ここまで来た時点で deleteUserIds には保存に成功した ID が入っている
            print("-------------\(deleteUserIds)--------------")
            if !deleteUserIds.isEmpty {
                do {
                    try realm.write {
                        for deleteUserId in deleteUserIds {
                            let objectsToDelete = realm.objects(HistoryData.self).where { $0.userId == deleteUserId }
                            realm.delete(objectsToDelete)
                        }
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

