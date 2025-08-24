//
//  UserRepository.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/14.
//

import Foundation
@preconcurrency import RealmSwift

actor UserRepository {
    var realm: Realm!
    
    init() async throws {
        realm = try await Realm(actor: self)
    }
    
    /// Userオブジェクトを受け取り、UserCacheとして保存・更新する
    func saveOrUpdate(users: [User]) async {
        do {
            // 1. [User] (structの配列) を [UserCache] (Realm Objectの配列) に変換
            let userCaches = users.map { UserCache(from: $0) }
            
            try await realm.asyncWrite {
                // 2. 変換した配列を、.modifiedオプション付きで一括で追加・更新
                realm.add(userCaches, update: .modified)
            }
        } catch {
            print("Error saving or updating multiple UserCaches: \(error)")
        }
    }
    
    func fetch(userIds: [String]) -> [User] {
        let cacheTTL: TimeInterval = CacheConfig.userProfileTTL
        let expirationDate = Date().addingTimeInterval(-cacheTTL) // 有効期限となる日時を計算
        
        let freshCaches = realm.objects(UserCache.self)
            .filter("id IN %@ AND lastUpdated > %@", userIds, expirationDate)
        
        return Array(freshCaches.map { $0.toModel() })
    }
    
    func fetch(userId: String) -> User? {
        let cacheTTL: TimeInterval = CacheConfig.userProfileTTL

        guard let userCache = realm.object(ofType: UserCache.self, forPrimaryKey: userId) else {
            return nil
        }
        
        // キャッシュが有効期限切れ（stale）でないかチェック
        if Date().timeIntervalSince(userCache.lastUpdated) > cacheTTL {
            return nil
        }
        
        // 新鮮なキャッシュはUserに変換して返す
        return userCache.toModel()
    }
}
