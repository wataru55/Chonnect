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
    
    /// userIdを指定して、キャッシュからUser（Struct）を取得する
    func fetch(userIds: [String]) -> [User] {
        // 1. "id IN %@" を使って、ID配列に一致するUserCacheを一度に全て取得する
        let userCaches = realm.objects(UserCache.self).filter("id IN %@", userIds)
        
        // 2. 取得した結果を、.toModel() を使って [User] (structの配列) に変換して返す
        return Array(userCaches.map { $0.toModel() })
    }
}
