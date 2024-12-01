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
    @Published var realtimeData: [EncountDataStruct] = []

    private var pendingHistoryUpdates: [String: Date] = [:]
    private var pendingRealtimeUpdates: [(String, Date, Int)] = []
    private var historyUpdateTimer: Timer?
    private var realtimeUpdateTimer: Timer?
    private let historyUpdateInterval: TimeInterval = 60.0
    private let realtimeUpdateInterval: TimeInterval = 10.0
    private var cancellables = Set<AnyCancellable>()

    // 初回更新フラグ
    private var shouldImmediatelyUpdateHistory = true
    private var shouldImmediatelyUpdateRealtime = true

    private init() {
        // 初期化時にRealmからデータを読み込む
        loadHistoryDataFromRealm()
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

    func storeData(_ receivedUserId: String, date: Date) {
        // 重複する更新を避ける
        if let existingDate = pendingHistoryUpdates[receivedUserId], existingDate == date {
            return
        }

        pendingHistoryUpdates[receivedUserId] = date

        // 初回は即時更新
        if shouldImmediatelyUpdateHistory {
            shouldImmediatelyUpdateHistory = false // フラグをリセット
            Task { @MainActor in
                self.processPendingHistoryUpdates()
            }
            return
        }

        if historyUpdateTimer == nil {
            historyUpdateTimer = Timer.scheduledTimer(withTimeInterval: historyUpdateInterval, repeats: false) { [weak self] _ in
                guard let self = self else { return }

                // メインアクターに切り替えて処理
                Task { @MainActor in
                    self.processPendingHistoryUpdates()
                }
            }
        }
    }

    private func processPendingHistoryUpdates() {
        let updatesToProcess = pendingHistoryUpdates
        pendingHistoryUpdates.removeAll()
        historyUpdateTimer = nil

        do {
            let realm = try Realm()
            try realm.write {
                for (userId, date) in updatesToProcess {
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
            // UIの更新
            loadHistoryDataFromRealm()
            print("Processed \(updatesToProcess.count) history updates in Realm.")
        } catch {
            print("Error processing history updates: \(error)")
        }
    }

    // バッチ処理用のstoreRealtimeDataメソッド
    func storeRealtimeData(receivedUserId: String, date: Date, rssi: Int) {
        pendingRealtimeUpdates.append((receivedUserId, date, rssi))

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
        let updatesToProcess = pendingRealtimeUpdates
        pendingRealtimeUpdates.removeAll()
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

