//
//  UserProfileRepository.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/08.
//

import Foundation
import OpenGraph
@preconcurrency import RealmSwift

// キャッシュの鮮度とデータを一緒に返すためのenum
enum CacheResult {
    // 新鮮なデータ
    case fresh(data: ProfileData)
    // 古いデータ（表示はできるが、裏側で更新が必要）
    case stale(data: ProfileData)

    case notFound
}

// UserProfileのキャッシュデータ操作を専門に担当するアクター
actor UserProfileRepository {
    var realm: Realm!

    init() async throws {
        realm = try await Realm(actor: self)
    }

    func saveOrUpdate(profileData: ProfileData) async {
        do {
            try await realm.asyncWrite {
                // UserProfileDataCacheオブジェクトを準備
                let profileCache = UserProfileDataCache()
                profileCache.id = profileData.user.id
                profileCache.lastUpdated = Date()

                // 各データをCache用のObjectに変換
                profileCache.user = UserCache(from: profileData.user)

                profileCache.follows.append(
                    objectsIn: profileData.follows.map { UserCache(from: $0) })
                profileCache.followers.append(
                    objectsIn: profileData.followers.map { UserCache(from: $0) })
                profileCache.skillTags.append(
                    objectsIn: profileData.skillTags.map { WordElementCache(from: $0) })

                let ogpCacheList = profileData.ogp.map { OpenGraphDataCache(from: $0) }
                profileCache.ogp.append(objectsIn: ogpCacheList)

                // .modifiedを指定することで、主キー(id)が同じデータがあれば更新、なければ新規追加する
                realm.add(profileCache, update: .modified)
            }
        } catch {
            print("Error saving or updating UserProfileDataCache: \(error)")
        }
    }

    /// 指定したIDのユーザープロフィールのキャッシュを取得する
    /// - Parameter userId: 取得したいユーザーのID
    /// - Returns: 復元されたプロフィールの各データ（タプル）。キャッシュがない場合はnil。
    func fetch(userId: String) -> CacheResult {
        guard
            let profileCache = realm.object(
                ofType: UserProfileDataCache.self, forPrimaryKey: userId)
        else {
            return .notFound  // キャッシュが存在しない
        }

        // 必須のユーザーデータがない場合は無効
        guard let user = profileCache.user?.toModel() else { return .notFound }

        // 各データを変換
        let follows = Array(profileCache.follows.map { $0.toModel() })
        let followers = Array(profileCache.followers.map { $0.toModel() })
        let skillTags = Array(profileCache.skillTags.map { $0.toModel() })
        let ogp = Array(profileCache.ogp.compactMap { $0.toModel() })

        let data = ProfileData(
            user: user, follows: follows, followers: followers, skillTags: skillTags, ogp: ogp)

        // --- TTLのチェックロジック ---
        // キャッシュの有効期限を1時間（3600秒）とする場合
        let isStale = Date().timeIntervalSince(profileCache.lastUpdated) > 3600

        if isStale {
            return .stale(data: data)
        } else {
            return .fresh(data: data)
        }
    }

}
