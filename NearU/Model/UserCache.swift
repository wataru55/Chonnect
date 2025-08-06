//
//  UserCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/06.
//

import Foundation
import RealmSwift

// Userモデルのキャッシュ用クラス
class UserCache: Object, ObjectKeyIdentifiable {
    // User.id -> primaryKeyとして設定
    @Persisted(primaryKey: true) var id: String
    // User.uid
    @Persisted var uid: String
    // User.username
    @Persisted var username: String
    // User.backgroundImageUrl
    @Persisted var backgroundImageUrl: String?
    // User.bio
    @Persisted var bio: String?
    // User.isPrivate
    @Persisted var isPrivate: Bool
    // User.snsLinks ([String: String]) -> RealmのMap<String, String>型で保存
    @Persisted var snsLinks: Map<String, String>
    // User.attributes ([String]) -> RealmのList<String>型で保存
    @Persisted var attributes: List<String>
    // User.interestTags ([String]) -> RealmのList<String>型で保存
    @Persisted var interestTags: List<String>
    // User.fcmtoken
    @Persisted var fcmtoken: String?
    
    // UserモデルからUserCacheを作成するためのイニシャライザ
    convenience init(from user: User) {
        self.init()
        self.id = user.id
        self.uid = user.uid
        self.username = user.username
        self.backgroundImageUrl = user.backgroundImageUrl
        self.bio = user.bio
        self.isPrivate = user.isPrivate
        self.fcmtoken = user.fcmtoken
        
        // 配列をListに変換
        self.attributes.append(objectsIn: user.attributes)
        self.interestTags.append(objectsIn: user.interestTags)
        
        // 辞書をMapに変換
        user.snsLinks.forEach { key, value in
            self.snsLinks[key] = value
        }
    }
}

extension UserCache {
    // UserCacheオブジェクトをUser構造体に変換する
    func toModel() -> User {
        // Mapを[String: String]に変換
        let snsLinksDictionary = self.snsLinks.reduce(into: [String: String]()) { result, element in
            result[element.key] = element.value
        }
        
        return User(
            id: self.id,
            uid: self.uid,
            username: self.username,
            backgroundImageUrl: self.backgroundImageUrl,
            bio: self.bio,
            isPrivate: self.isPrivate,
            snsLinks: snsLinksDictionary,
            attributes: Array(self.attributes), // Listを[String]に変換
            interestTags: Array(self.interestTags), // Listを[String]に変換
            fcmtoken: self.fcmtoken
        )
    }
}
