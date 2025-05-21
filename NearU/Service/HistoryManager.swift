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

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    private var realmService: RealmService?

    private var pendingHistoryData: [(userId: String, date: Date, isRead: Bool)] = []
    // 10秒ごとにpendingHistoryDataを Realm に書き込むタイマー
    private var historyBatchTimer: Timer?
    // 30秒ごとに Realm → Firestore → Realm削除するタイマー
    private var firestoreSyncTimer: Timer?
    
    /// 10秒に一度履歴をバッチ書き込み
    private let historyBatchInterval: TimeInterval = 10.0
    /// 30秒に一度 Firestore 同期＆削除
    private let firestoreSyncInterval: TimeInterval = 30.0
    
    private var isInForeground: Bool {
        return UIApplication.shared.applicationState == .active
    }

    init() {
        Task {
            do {
                let service = try await RealmService()
                self.realmService = service
            } catch {
                print("Failed to initialize RealmService: \(error)")
            }
        }
        // --- 10秒おきのバッチ処理 (Realm書き込み) ---
        historyBatchTimer = Timer.scheduledTimer(withTimeInterval: historyBatchInterval,
                                                 repeats: true) { [weak self] _ in
            Task {
                self?.saveHistoryDataToRealm()  // 10秒に1回、メモリ→Realm
            }
        }
        
        // --- 30秒おきのFirestore同期＆Realm削除 ---
        firestoreSyncTimer = Timer.scheduledTimer(withTimeInterval: firestoreSyncInterval,
                                                  repeats: true) { [weak self] _ in
            Task {
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
            Task {
                await realmService?.saveHistoryData(userId: receivedUserId, date: date, isRead: false)
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
        
        Task {
            guard let service = realmService else {
                return
            }
            
            for (userId, date, isRead) in updatesToProcess {
                await service.saveHistoryData(userId: userId, date: date, isRead: isRead)
            }
        }
    }
    
    // Realm上の履歴データをFirestoreに保存し、成功したものをRealmから削除するメソッド
    private func syncHistoryDataToFireStore() async {
        guard let service = realmService else {
            return
        }
        // Realmから履歴データを読み込み
        let historyDataList = await service.fetchAllHistoryData()
        guard !historyDataList.isEmpty else { return }
            
        var deleteUserIds: [String] = []
        
        // for文で逐次 await しながら Firestore に保存
        for structHistoryData in historyDataList {
            do {
                // Firestore への保存を待機
                print("---------------savetoFireStore------------------")
                try await HistoryService.saveHistoryUser(historyData: structHistoryData)
                
                deleteUserIds.append(structHistoryData.userId)
            } catch {
                print("Failed to save userId \(structHistoryData.userId): \(error)")
            }
        }
        
        // ここまで来た時点で deleteUserIds には保存に成功した ID が入っている
        if !deleteUserIds.isEmpty {
            await service.deleteHistoryData(for: deleteUserIds)
        } else {
            print("No HistoryData was successfully synced this time.")
        }
    }
}

