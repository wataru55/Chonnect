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

class RealtimeDataManager: ObservableObject {
    static let shared = RealtimeDataManager()
    
    @Published var realtimeData: [EncountDataStruct] = []
    
    private var pendingRealtimeData: [(userId: String, date: Date, rssi: Int)] = []
    private var realtimeUpdateTimer: Timer?
    private let realtimeUpdateInterval: TimeInterval = 10.0
    
    private var shouldImmediatelyUpdateRealtime = true
    
    // ユーザーごとにKalmanFilterを管理する辞書
    private var kalmanFilters: [String: KalmanFilter] = [:]
    
    deinit {
        realtimeUpdateTimer?.invalidate()
    }
    
    // データをメモリ上で管理
    func storeRealtimeData(receivedUserId: String, date: Date, rssi: Int) {
        pendingRealtimeData.append((receivedUserId, date, rssi))
        
        // 初回は即時更新
        if shouldImmediatelyUpdateRealtime {
            shouldImmediatelyUpdateRealtime = false
            processPendingRealtimeUpdates()
            return
        }
        
        // タイマーで一定間隔ごとにバッチ処理
        if realtimeUpdateTimer == nil {
            realtimeUpdateTimer = Timer.scheduledTimer(withTimeInterval: realtimeUpdateInterval, repeats: false) { [weak self] _ in
                self?.processPendingRealtimeUpdates()
            }
        }
    }
    
    private func processPendingRealtimeUpdates() {
        for (userId, date, rssi) in pendingRealtimeData {
            // ユーザーに対応するカルマンフィルタを取得または作成
            let kalmanFilter = kalmanFilters[userId] ?? KalmanFilter(
                initialEstimate: Double(rssi)
            )
            
            kalmanFilters[userId] = kalmanFilter
            
            // RSSI値をスムージング
            let smoothedRSSI = kalmanFilter.smoothing(measurement: Double(rssi))
            
            if let index = realtimeData.firstIndex(where: { $0.userId == userId }) {
                // 既存データを更新
                realtimeData[index].date = date
                // realtimeData[index].rssi = rssi
                // カルマンフィルタによってスムージングされた値を格納
                realtimeData[index].rssi = Int(smoothedRSSI)
            } else {
                // 新しいデータを追加
                realtimeData.append(EncountDataStruct(userId: userId, date: date, rssi: rssi))
                // カルマンフィルタによってスムージングされた値を格納
                realtimeData.append(EncountDataStruct(userId: userId, date: date, rssi: Int(smoothedRSSI)))
            }
        }
        pendingRealtimeData.removeAll()
        realtimeUpdateTimer = nil
    }
    
    func removeOutdatedData(interval: TimeInterval = 30.0) {
        let thresholdDate = Date().addingTimeInterval(-interval)
        realtimeData.removeAll { $0.date <= thresholdDate }
    }
}
