//
//  UserProfileDataCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/06.
//

import Foundation
import RealmSwift

// ユーザーのプロフィール全体のキャッシュデータ
class UserProfileDataCache: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var user: UserCache? // 1対1の関係
    @Persisted var follows: List<UserCache> // 1対多の関係
    @Persisted var followers: List<UserCache> // 1対多の関係
    @Persisted var skillTags: List<WordElementCache>
    @Persisted var ogp: List<OpenGraphDataCache>
    @Persisted var lastUpdated: Date = Date() // キャッシュの更新日時
}
