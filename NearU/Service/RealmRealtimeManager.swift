//
//  RealmRealtimeManager.swift
//  NearU
//
//  Created by 高橋和 on 2024/12/30.
//

import SwiftUI
import RealmSwift
import FirebaseFirestore
import Combine

@MainActor
class RealmRealtimeManager: ObservableObject {
    static let shared = RealmRealtimeManager()
    
    @Published var realtimeData: [EncountDataStruct] = []
    
    private var pendingRealtimeData: [(userId: String, date: Date, rssi: Int)] = []
    private var realtimeUpdateTimer: Timer?
    private let realtimeUpdateInterval: TimeInterval = 10.0
    
    private var cancellables = Set<AnyCancellable>()
    
    private var shouldImmediatelyUpdateRealtime = true
    
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
    
    // バッチ処理用のstoreRealtimeDataメソッド
    func storeRealtimeData(receivedUserId: String, date: Date, rssi: Int) {
        pendingRealtimeData.append((receivedUserId, date, rssi))

        // 初回は即時更新
        if shouldImmediatelyUpdateRealtime {
            shouldImmediatelyUpdateRealtime = false // フラグをリセット
            Task { @MainActor in
                self.processPendingRealtimeUpdates()
            }
            return
        }

        if realtimeUpdateTimer == nil {
            realtimeUpdateTimer = Timer.scheduledTimer(withTimeInterval: realtimeUpdateInterval, repeats: false) { [weak self] _ in
                guard let self = self else { return }

                // メインアクターに切り替えて処理
                Task { @MainActor in
                    self.processPendingRealtimeUpdates()
                }
            }
        }
    }
    
    private func processPendingRealtimeUpdates() {
        let updatesToProcess = pendingRealtimeData
        pendingRealtimeData.removeAll()
        realtimeUpdateTimer = nil

        do {
            let realm = try Realm()
            try realm.write {
                for (userId, date, rssi) in updatesToProcess {
                    if let existingRealtimeData = realm.objects(EncountData.self).filter("userId == %@", userId).first {
                        existingRealtimeData.date = date
                        existingRealtimeData.rssi = rssi
                    } else {
                        let newRealtimeData = EncountData()
                        newRealtimeData.userId = userId
                        newRealtimeData.date = date
                        newRealtimeData.rssi = rssi
                        realm.add(newRealtimeData)
                    }
                }
            }
            // UIの更新
            loadRealtimeDataFromRealm()
            print("Processed \(updatesToProcess.count) realtime updates in Realm.")
        } catch {
            print("Error processing realtime updates: \(error)")
        }
    }
    
    // 古いリアルタイムデータを削除するメソッド
    func removeRealtimeData(interval: TimeInterval = 15.0) {
        guard !realtimeData.isEmpty else { return }
        do {
            let realm = try Realm()
            let removeDate = Date().addingTimeInterval(-interval)
            let outdatedUsers = realm.objects(EncountData.self).filter("date <= %@", removeDate)

            if !outdatedUsers.isEmpty {
                // 削除前にuserIdリストを取得
                let outdatedUserIds = Array(outdatedUsers.map { $0.userId })

                try realm.write {
                    realm.delete(outdatedUsers)
                }
                // メモリ上のrealtimeData配列からも削除
                realtimeData.removeAll { outdatedUserIds.contains($0.userId) }
            }
        } catch {
            print("Error during cleanup: \(error)")
        }
    }
    
}
